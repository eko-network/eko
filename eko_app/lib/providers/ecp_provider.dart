import 'package:ecp/ecp.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/utilities/device_uid_service.dart';
import 'package:eko_app/utilities/ecp_helpers.dart' as ecp_helpers;
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

@Riverpod(keepAlive: true)
Future<EcpClient> asyncEcpClient(Ref ref) async {
  ref.listen(authProvider, (_, next) {
    if (next.value?.uid == null) ref.invalidateSelf();
  });

  final core = ref.watch(authProvider.notifier).core;
  final session = supabase.auth.currentSession;
  assert(core != null && session != null,
      'EcpClient accessed before auth or on web');
  final httpClient =
      AuthenticatedClient(() => supabase.auth.currentSession?.accessToken);

  ref.onDispose(() {
    httpClient.close();
  });

  final client = EcpClient.build(
      core: core!,
      did: DeviceUidService.getOrCreate(),
      client: httpClient,
      me: ecp_helpers.buildPerson(uid: session!.user.id));
  return client;
}

@Riverpod(keepAlive: true)
EcpClient ecpClient(Ref ref) {
  return ref.watch(asyncEcpClientProvider).requireValue;
}
