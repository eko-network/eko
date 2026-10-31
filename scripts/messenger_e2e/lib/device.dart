import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:ecp/ecp.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'memory_storage.dart';

class Env {
  final Uri supabaseUrl;
  final String anonKey;
  final Uri messengerUrl;

  const Env({
    required this.supabaseUrl,
    required this.anonKey,
    required this.messengerUrl,
  });
}

class RpcException implements Exception {
  final int status;
  final String body;
  RpcException(this.status, this.body);

  @override
  String toString() => 'RpcException($status): $body';
}

/// One signed-in app install: a Supabase session, a device id and an
/// [EcpClient] backed by in-memory storage. Mirrors what the app does in
/// ecp_core_provider.dart / ecp_provider.dart.
class SimDevice {
  final Env env;
  final String name;
  final String email;
  final String did = const Uuid().v7();
  final storage = MemoryStorage();
  final _http = http.Client();

  late String uid;
  late String _accessToken;
  late String _refreshToken;
  late EcpCore core;
  late EcpClient client;
  late MlsCredentialRecord credential;

  SimDevice(this.env, this.name, this.email);

  Map<String, dynamic> get claims {
    final payload = _accessToken.split('.')[1];
    return jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(payload))),
        )
        as Map<String, dynamic>;
  }

  Map<String, dynamic> get _appMetadata =>
      (claims['app_metadata'] as Map?)?.cast<String, dynamic>() ?? {};

  /// The device id the access token carries, set once the device is registered.
  String? get tokenDid => _appMetadata['did'] as String?;

  /// Set once the device is approved.
  bool get approved => _appMetadata['dat'] != null;

  Person get person => personFor(uid);

  Person personFor(String uid) => Person.fromId(
    env.messengerUrl.replace(
      pathSegments: [
        ...env.messengerUrl.pathSegments.where((s) => s.isNotEmpty),
        'users',
        uid,
      ],
    ),
  );

  Future<void> signIn() async {
    final res = await _http.post(
      env.supabaseUrl.replace(
        path: '/auth/v1/token',
        queryParameters: {'grant_type': 'password'},
      ),
      headers: {'apikey': env.anonKey, 'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': 'password'}),
    );
    _takeSession(res);
    uid = (jsonDecode(res.body) as Map)['user']['id'] as String;
  }

  Future<void> refreshSession() async {
    final res = await _http.post(
      env.supabaseUrl.replace(
        path: '/auth/v1/token',
        queryParameters: {'grant_type': 'refresh_token'},
      ),
      headers: {'apikey': env.anonKey, 'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': _refreshToken}),
    );
    _takeSession(res);
  }

  void _takeSession(http.Response res) {
    if (res.statusCode != 200) {
      throw StateError('[$name] auth failed (${res.statusCode}): ${res.body}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    _accessToken = body['access_token'] as String;
    _refreshToken = body['refresh_token'] as String;
  }

  Future<dynamic> rpc(String fn, Map<String, dynamic> params) async {
    final res = await _http.post(
      env.supabaseUrl.replace(path: '/rest/v1/rpc/$fn'),
      headers: {
        'apikey': env.anonKey,
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(params),
    );
    if (res.statusCode >= 300) throw RpcException(res.statusCode, res.body);
    return res.body.isEmpty ? null : jsonDecode(res.body);
  }

  Future<List<Map<String, dynamic>>> selectDevices() async {
    final res = await _http.get(
      env.supabaseUrl.replace(
        path: '/rest/v1/devices',
        queryParameters: {'select': 'id,approved_at'},
      ),
      headers: {'apikey': env.anonKey, 'Authorization': 'Bearer $_accessToken'},
    );
    if (res.statusCode >= 300) throw RpcException(res.statusCode, res.body);
    return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
  }

  /// Sign in, create the MLS identity, register the device and refresh the
  /// token so it carries the did (and dat when trusted on first use). A
  /// pending device then asks the user's other devices for approval.
  Future<void> setUp() async {
    await signIn();
    final random = Random.secure();
    core = EcpCore(
      storage: storage,
      identity: person,
      engineConfig: MlsEngineConfig(
        dbPath: ':memory:',
        encryptionKey: Uint8List.fromList(
          List.generate(32, (_) => random.nextInt(256)),
        ),
      ),
    );
    await core.open();
    final (cred, keyPackages) = await core.createIdentity();
    credential = cred;
    final genesis = await DeviceChainEntry.genesis(
      actor: person.id,
      did: did,
      credential: cred,
    );
    await rpc('register_device', {
      'p_did': did,
      'p_signer_public_key': base64Encode(cred.signerPublicKey),
      'p_key_packages': keyPackages
          .map((k) => base64Encode(k.keyPackageBytes))
          .toList(),
      'p_chain_entry': genesis.toJson(),
      'p_chain_hash': base64Encode(genesis.hash),
    });
    await refreshSession();
    client = await EcpClient.build(
      did: did,
      client: _AuthClient(() => _accessToken),
      core: core,
    );
    if (!approved) {
      await client.messages.sendApprovalRequest(
        publicKey: cred.signerPublicKey,
        did: did,
      );
    }
  }

  /// Pull the inbox and return the messages it produced.
  Future<List<StoredMessage>> sync() => client.getInbox();

  /// Approves another device of this user, what the approval screen does.
  Future<void> approve(String otherDid, Uint8List publicKey) async {
    final entry = await client.devices.approve(
      did: otherDid,
      publicKey: publicKey,
    );
    await rpc('approve_device', {
      'did': otherDid,
      'p_entry': entry.toJson(),
      'p_hash': base64Encode(entry.hash),
    });
  }

  /// Removes a device of this user, this one included, revoking it in the
  /// chain when it was approved.
  Future<void> removeDevice(String otherDid) async {
    final entry = await client.devices.revoke(did: otherDid);
    await rpc('remove_device', {
      'p_did': otherDid,
      if (entry != null) ...{
        'p_entry': entry.toJson(),
        'p_hash': base64Encode(entry.hash),
      },
    });
  }

  /// What the app does on sign out.
  Future<void> signOut() async {
    await removeDevice(did);
    await close();
  }

  Future<void> close() async {
    await client.close();
    _http.close();
  }

  Future<void> sendText(Uint8List groupId, String text) =>
      client.messages.sendMessage(
        Activity.newCreate(object: ActivityPubObject.newNote(content: text)),
        groupId,
      );
}

class _AuthClient extends http.BaseClient {
  final String Function() _token;
  final _inner = http.Client();

  _AuthClient(this._token);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer ${_token()}';
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
