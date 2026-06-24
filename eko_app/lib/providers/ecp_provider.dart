import 'dart:async';

import 'package:ecp/ecp.dart';
import 'package:eko_app/messenger/utilities/authenticated_http_client.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/ecp_core_provider.dart';
import 'package:eko_app/utilities/device_uid_service.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part '../generated/providers/ecp_provider.g.dart';

Duration? _asyncEcpClientNoRetry(int retryCount, Object error) => null;

@Riverpod(keepAlive: true, retry: _asyncEcpClientNoRetry)
Future<EcpClient> asyncEcpClient(Ref ref) async {
  ref.listen(authProvider, (prev, next) {
    if (next.isLoading) return;
    final prevUid = prev?.value?.uid;
    final nextUid = next.value?.uid;
    if (nextUid != null && prevUid != nextUid) {
      ref.invalidateSelf();
    }
  });

  final uid = ref.watch(authProvider).value?.uid;
  if (uid == null) {
    throw StateError('EcpClient accessed before auth is ready');
  }

  final core = await ref.watch(ecpCoreHolderProvider.future);
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

  return EcpClient.build(
    core: core,
    did: DeviceUidService.getOrCreate(),
    client: httpClient,
    tokenGetter: () => supabase.auth.currentSession?.accessToken ?? '',
  );
}

@Riverpod()
EcpClient ecpClient(Ref ref) {
  return ref.watch(asyncEcpClientProvider).requireValue;
}

@Riverpod(keepAlive: true)
void inboxPolling(Ref ref) {
  StreamSubscription<dynamic>? subscription;
  MessageStreamController? controller;

  void stop() {
    subscription?.cancel();
    subscription = null;
    controller = null;
  }

  void start(EcpClient client) {
    stop();
    controller = MessageStreamController(
      client: client,
      config: MessageStreamConfig(useWebSocket: true),
    );
    subscription = controller!.messages().listen((_) {});
  }

  ref.listen(asyncEcpClientProvider, (previous, next) {
    if (next.hasValue) {
      start(next.requireValue);
    } else if (next.hasError) {
      stop();
    }
  }, fireImmediately: true);

  ref.onDispose(stop);
}
