import 'package:ecp/ecp.dart';
import 'package:eko_app/database/daos/ecp/storage.dart';
import 'package:eko_app/database/database.dart';
import 'package:eko_app/database/ecp_session_store.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/types/ecp_session.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../generated/providers/ecp_session_provider.g.dart';

class _StaticTokenProvider implements TokenProvider {
  _StaticTokenProvider(this._token);
  final String _token;

  @override
  Future<String?> getAccessToken() async => _token;
}

@Riverpod(keepAlive: true)
class EcpSessionHolder extends _$EcpSessionHolder {
  EcpClient? _client;

  @override
  Future<EcpSession?> build() async {
    ref.listen(authProvider, (previous, next) {
      if (previous?.uid != next.uid) {
        ref.invalidateSelf();
      }
    });

    final uid = ref.watch(authProvider).uid;
    if (uid == null || uid.isEmpty) {
      await _closeClient();
      return null;
    }

    final session = await EcpSessionStore(db).load();
    if (session == null || session.isExpired) {
      await _closeClient();
      return session;
    }

    await _ensureClient(session);
    return session;
  }

  Future<void> _ensureClient(EcpSession session) async {
    if (_client != null) return;
    try {
      _client = await EcpClient.build(
        storage: DriftStorage(db),
        client: http.Client(),
        me: session.actor,
        did: session.did,
        tokenProvider: _StaticTokenProvider(session.accessToken),
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

  Future<void> refreshSession() async {
    await _closeClient();
    ref.invalidateSelf();
  }
}
