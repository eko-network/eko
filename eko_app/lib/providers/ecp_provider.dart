import 'package:ecp/ecp.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/utilities/device_uid_service.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
part '../generated/providers/ecp_provider.g.dart';

class AuthenticatedClient extends http.BaseClient {
  final String? Function() _getToken;
  final http.Client _inner;

  AuthenticatedClient(this._getToken) : _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = _getToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

@Riverpod()
Future<EcpClient> asyncEcpClient(Ref ref) async {
  ref.listen(authProvider, (prev, next) {
    final prevUid = prev?.value?.uid;
    final nextUid = next.value?.uid;
    if (nextUid != null && prevUid != nextUid) {
      ref.invalidateSelf();
    }
  });

  final uid = ref.read(authProvider).value?.uid;
  if (uid == null) {
    throw StateError('EcpClient accessed before auth is ready');
  }

  final core = ref.read(authProvider.notifier).core;
  final session = supabase.auth.currentSession;
  if (core == null || session == null) {
    throw StateError('EcpClient accessed before auth or on web');
  }
  final httpClient = AuthenticatedClient(
    () => supabase.auth.currentSession?.accessToken,
  );

  ref.onDispose(() {
    httpClient.close();
  });

  final client = EcpClient.build(
    core: core,
    did: DeviceUidService.getOrCreate(),
    client: httpClient,
    tokenGetter: () => supabase.auth.currentSession?.accessToken ?? '',
  );
  return client;
}

@Riverpod()
EcpClient ecpClient(Ref ref) {
  return ref.watch(asyncEcpClientProvider).requireValue;
}

@Riverpod(keepAlive: true)
void inboxPolling(Ref ref) {
  final client = ref.watch(asyncEcpClientProvider).requireValue;
  final controller = MessageStreamController(
    client: client,
    config: MessageStreamConfig(useWebSocket: true),
  );
  controller.messages().listen((_) {});
}
