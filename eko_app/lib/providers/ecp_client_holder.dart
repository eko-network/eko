import 'package:ecp/ecp.dart';
import 'package:eko_app/database/daos/ecp/storage.dart';
import 'package:eko_app/database/database.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/utilities/ecp_person.dart';
import 'package:eko_app/utilities/supabase_ecp_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../generated/providers/ecp_client_holder.g.dart';

@Riverpod(keepAlive: true)
class EcpClientHolder extends _$EcpClientHolder {
  EcpClient? _client;

  @override
  Future<EcpClient?> build() async {
    ref.listen(authProvider, (previous, next) {
      if (previous?.uid != next.uid) {
        ref.invalidateSelf();
      }
    });

    final auth = ref.watch(authProvider);
    if (auth.uid == null ||
        auth.uid!.isEmpty ||
        auth.did == null ||
        auth.did!.isEmpty) {
      await _closeClient();
      return null;
    }

    await _ensureClient(auth.uid!, auth.did!);
    return _client;
  }

  Future<void> _ensureClient(String uid, String did) async {
    if (_client != null) return;
    try {
      final user = ref.read(currentUserProvider).user;
      final username = user.username.isNotEmpty ? user.username : uid;
      final me = buildMessengerPerson(
        supabaseUid: uid,
        preferredUsername: username,
      );
      _client = await EcpClient.build(
        storage: DriftStorage(db),
        client: http.Client(),
        me: me,
        did: messengerDeviceId(uid, did),
        tokenProvider: supabaseTokenProvider,
        requestAuthenticator: supabaseRequestAuthenticator,
      );
    } catch (e, st) {
      debugPrint('Failed to build EcpClient: $e\n$st');
      _client = null;
    }
  }

  Future<void> _closeClient() async {
    final client = _client;
    _client = null;
    if (client != null) {
      await client.close();
    }
  }

  EcpClient? get client => _client;

  Future<void> rebuildClient() async {
    await _closeClient();
    ref.invalidateSelf();
  }
}
