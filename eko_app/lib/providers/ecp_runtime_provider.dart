import 'dart:convert';
import 'dart:math';
import 'package:ecp/ecp.dart';
import 'package:eko_app/database/daos/ecp/storage.dart';
import 'package:eko_app/database/database.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/utilities/device_uid_service.dart';
import 'package:eko_app/utilities/ecp_person.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:eko_app/utilities/supabase_ecp_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<MlsEngineConfig> _engineConfig() async {
  const secureStorage = FlutterSecureStorage();
  var storedKey = await secureStorage.read(key: 'mls_engine_key');
  if (storedKey == null) {
    final random = Random.secure();
    final key = Uint8List(32);
    for (var i = 0; i < 32; i++) {
      key[i] = random.nextInt(256);
    }
    storedKey = base64Encode(key);
    await secureStorage.write(key: 'mls_engine_key', value: storedKey);
  }
  final dir = await getApplicationSupportDirectory();
  return MlsEngineConfig(
    dbPath: p.join(dir.path, 'mls.db'),
    encryptionKey: Uint8List.fromList(base64Decode(storedKey)),
  );
}

final ecpRuntimeProvider =
    AsyncNotifierProvider<EcpRuntimeProvider, EcpClient?>(
        EcpRuntimeProvider.new);

final ecpClientProvider = Provider<EcpClient>((ref) {
  final client = ref.watch(ecpRuntimeProvider).asData?.value;
  assert(client != null, 'ecpClientProvider used before ECP is ready');
  return client!;
});

final ecpRuntimeReadyProvider = Provider<bool>((ref) {
  final auth = ref.watch(authProvider);
  final uid = auth.uid;
  final did = auth.did;
  if (uid == null || uid.isEmpty || did == null || did.isEmpty) {
    return false;
  }
  final holder = ref.watch(ecpRuntimeProvider);
  final notifier = ref.watch(ecpRuntimeProvider.notifier);
  if (holder.isLoading || holder.hasError || holder.asData?.value == null) {
    return false;
  }
  return notifier.isReadyFor(uid, did);
});

class EcpRuntimeProvider extends AsyncNotifier<EcpClient?> {
  EcpCore? _core;
  String? _coreKey;
  Future<void>? _coreInitInFlight;
  String? _coreInitInFlightKey;

  EcpClient? _client;
  String? _clientUid;
  String? _clientDid;
  Object _buildEpoch = Object();

  @override
  Future<EcpClient?> build() async {
    ref.listen(authProvider, (previous, next) {
      if (previous?.uid != next.uid || previous?.did != next.did) {
        _buildEpoch = Object();
        ref.invalidateSelf();
      }
    });
    final buildEpoch = _buildEpoch;

    final auth = ref.watch(authProvider);
    final uid = auth.uid;
    final did = auth.did;

    if (uid == null || uid.isEmpty || did == null || did.isEmpty) {
      await _closeClient();
      await _disposeCore();
      return null;
    }

    final core = await _ensureCore(uid, did);
    if (!identical(buildEpoch, _buildEpoch) || core == null) return null;

    await _ensureClient(uid, did, core);
    if (!identical(buildEpoch, _buildEpoch)) return null;
    if (!isReadyFor(uid, did)) return null;
    return _client;
  }

  Future<EcpCore?> _ensureCore(String uid, String did) async {
    final key = '$uid::$did';
    if (_coreKey == key) return _core;

    if (_coreInitInFlight != null) {
      await _coreInitInFlight;
      if (_coreKey == key) return _core;
    }

    _coreInitInFlightKey = key;
    _coreInitInFlight = () async {
      final storage = DriftStorage(db);
      final existingCredential =
          await storage.mlsCredentialStore.getCredential();
      final core = EcpCore(
        storage: storage,
        credentialIdentity: Uint8List.fromList(utf8.encode(uid)),
        engineConfig: await _engineConfig(),
      );
      await core.open();

      if (existingCredential == null) {
        final identity = await core.CreateIdentity();
        final credential = identity.$1;
        final keyPackages = identity.$2;
        await storage.mlsCredentialStore.saveCredential(credential);

        final deviceUid = DeviceUidService.getOrCreate();
        await supabase.rpc('register_device', params: {
          'p_did': deviceUid,
          'p_signer_public_key': base64Encode(credential.signerPublicKey),
        });

        if (keyPackages.isNotEmpty) {
          await supabase.rpc('add_key_packages', params: {
            'p_did': deviceUid,
            'p_key_packages': keyPackages
                .map((it) => base64Encode(it.keyPackageBytes))
                .toList(),
          });
        }
        await supabase.auth.refreshSession();
      }

      if (_core != null && !identical(_core, core)) {
        await _core!.close();
      }
      _core = core;
      _coreKey = key;
    }();

    try {
      await _coreInitInFlight;
    } catch (_) {
      if (_coreInitInFlightKey == key && _core != null) {
        await _core!.close();
        _core = null;
      }
      rethrow;
    } finally {
      _coreInitInFlight = null;
      _coreInitInFlightKey = null;
    }

    return _core;
  }

  Future<void> _disposeCore() async {
    if (_core != null) {
      await _core!.close();
      _core = null;
    }
    _coreKey = null;
  }

  Future<void> _ensureClient(String uid, String did, EcpCore core) async {
    if (isReadyFor(uid, did)) return;
    await _closeClient();
    try {
      final me = buildMessengerPerson(supabaseUid: uid);
      _client = await EcpClient.build(
        storage: DriftStorage(db),
        client: http.Client(),
        me: me,
        did: did,
        tokenProvider: supabaseTokenProvider,
        requestAuthenticator: supabaseRequestAuthenticator,
        core: core,
      );
      _clientUid = uid;
      _clientDid = did;
    } catch (e, st) {
      debugPrint('Failed to build EcpClient: $e\n$st');
      _client = null;
      _clientUid = null;
      _clientDid = null;
    }
  }

  Future<void> _closeClient() async {
    final client = _client;
    _client = null;
    _clientUid = null;
    _clientDid = null;
    if (client != null) {
      await client.close();
    }
  }

  bool isReadyFor(String uid, String did) =>
      _client != null && _clientUid == uid && _clientDid == did;

  EcpClient? get client => _client;

  Future<void> rebuildClient() async {
    await _closeClient();
    ref.invalidateSelf();
  }
}
