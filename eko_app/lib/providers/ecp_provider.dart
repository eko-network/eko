import 'dart:async';

import 'package:ecp/ecp.dart';
import 'package:eko_app/messenger/utilities/authenticated_http_client.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/ecp_core_provider.dart';
import 'package:eko_app/services/messenger_notification_service.dart';
import 'package:eko_app/utilities/device_uid_service.dart';
import 'package:eko_app/utilities/platform.dart' as platform;
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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

  final holder = ref.read(ecpCoreHolderProvider.notifier);
  final httpClient = AuthenticatedClient(
    freshAccessToken,
    onDeviceRemoved: () => unawaited(holder.checkDeviceRemoved()),
  );

  ref.onDispose(() {
    httpClient.close();
  });

  return EcpClient.build(
    core: core,
    did: DeviceUidService.getOrCreate(),
    client: httpClient,
    tokenGetter: () async => await freshAccessToken() ?? '',
  );
}

@Riverpod()
EcpClient ecpClient(Ref ref) {
  return ref.watch(asyncEcpClientProvider).requireValue;
}

const _backgroundTaskChannel = MethodChannel('PushNotificationChannel');

/// iOS ends an app that is suspended holding the MLS database's lock, which
/// the notification service shares, so it is let go of in the background, see
/// [EcpCore.suspend]. A background task keeps the app running until then.
Future<void> _suspendInBackground(
  MessageStreamController controller,
  EcpCore core,
) async {
  controller.pause();
  int? task;
  try {
    task = await _backgroundTaskChannel.invokeMethod<int>(
      'beginBackgroundTask',
    );
  } on PlatformException catch (e) {
    debugPrint('[Messenger] no background task: $e');
  }
  try {
    await core.suspend();
  } finally {
    if (task != null) {
      await _backgroundTaskChannel.invokeMethod('endBackgroundTask', task);
    }
  }
}

Future<void> _resumeInForeground(
  MessageStreamController controller,
  EcpClient client,
) async {
  try {
    await client.core.resume();
  } catch (e) {
    // the core opens the engine for each action meanwhile
    debugPrint('[Messenger] resume failed: $e');
  }
  controller.resume();
  try {
    // stores what the notification service decrypted meanwhile
    await client.getInbox();
  } catch (e) {
    debugPrint('[Messenger] inbox after resume failed: $e');
  }
}

@Riverpod(keepAlive: true)
void inboxPolling(Ref ref) {
  StreamSubscription<dynamic>? subscription;
  MessageStreamController? controller;
  AppLifecycleListener? lifecycle;

  void stop() {
    MessengerNotificationService.unregisterMainIsolate();
    lifecycle?.dispose();
    lifecycle = null;
    subscription?.cancel();
    subscription = null;
    controller = null;
  }

  void start(EcpClient client) {
    stop();
    final me = client.core.identity.id;
    controller = MessageStreamController(
      client: client,
      config: MessageStreamConfig(useWebSocket: true),
    );
    subscription = controller!.messages().listen(
      (messages) =>
          MessengerNotificationService.showForMessages(messages, me: me),
    );
    // the websocket may have been dropped while in the background
    MessengerNotificationService.registerMainIsolate(() async {
      final messages = await client.getInbox();
      await MessengerNotificationService.showForMessages(messages, me: me);
    });
    if (platform.isIOS) {
      final started = controller!;
      void suspend() => unawaited(_suspendInBackground(started, client.core));
      lifecycle = AppLifecycleListener(
        onHide: suspend,
        onResume: () => unawaited(_resumeInForeground(started, client)),
      );
      // e.g. launched in the background, which shows nothing
      final state = WidgetsBinding.instance.lifecycleState;
      if (state == AppLifecycleState.hidden ||
          state == AppLifecycleState.paused) {
        suspend();
      }
    }
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
