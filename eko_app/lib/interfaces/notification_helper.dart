import 'dart:async';
import 'dart:convert';
import 'package:eraser/eraser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/providers/following_feed_provider.dart';
import 'package:eko_app/providers/new_feed_provider.dart';
import 'package:eko_app/providers/popular_feed_provider.dart';
import 'package:eko_app/utilities/api_constants.dart' as ac;
import 'package:eko_app/utilities/shared_pref_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:unifiedpush_platform_interface/unifiedpush_platform_interface.dart';
import 'package:unifiedpush_storage_shared_preferences/storage.dart';
import 'package:eko_app/utilities/platform.dart' as platform;

part 'notification_helper_apn.dart';
part 'notification_helper_up.dart';

class NotificationHelper {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static NotificationPlatformAdapter get _adapter {
    if (platform.isIOS) {
      const MethodChannel channel = MethodChannel('PushNotificationChannel');
      return const ApnsNotificationAdapter(channel);
    }
    if (platform.isAndroid || platform.isLinux) {
      return const UnifiedPushNotificationAdapter();
    }
    return const NoopNotificationAdapter();
  }

  static Future<void> setupNotifications() async {
    await _adapter.initialize();
    await _adapter.requestPermissions();
    if (_adapter.registersDuringSetup) {
      await _adapter.registerDevice();
    }
  }

  static Future<void> bootstrapUnifiedPushBackground(List<String> args) async {
    if (!args.contains('--unifiedpush-bg')) return;
    if (platform.isAndroid) {
      debugPrint('[UnifiedPush] bootstrap background entrypoint');
      await const UnifiedPushNotificationAdapter().initialize();
      if (await UnifiedPush.getDistributor() != null) {
        await UnifiedPush.register(
          instance: UnifiedPushNotificationAdapter.instanceId,
          vapid: ac.vapidPublicKey,
        );
      }
      return;
    }
    if (platform.isLinux) {
      UnifiedPushNotificationAdapter.markLinuxBackgroundLaunch();
      try {
        debugPrint('[UnifiedPush] bootstrap linux background entrypoint');
        await const UnifiedPushNotificationAdapter().initialize();
        if (await UnifiedPush.getDistributor() != null) {
          await UnifiedPush.register(
            instance: UnifiedPushNotificationAdapter.instanceId,
            vapid: ac.vapidPublicKey,
          );
        }
      } finally {
        UnifiedPushNotificationAdapter.clearLinuxBackgroundLaunch();
      }
    }
  }

  /// For when a user clicks on a notification they received
  static void setupHandlersWithContext(
    BuildContext context,
    void Function() callback,
  ) {
    _adapter.setHandlers(context, callback, _handleNavigationPayload);
  }

  static Future<String?> getDeviceToken({bool forBackendSync = false}) async {
    await _adapter.initialize();
    return _adapter.getDeviceToken(forBackendSync: forBackendSync);
  }

  static Future<String?> waitForDeviceToken({
    Duration timeout = const Duration(seconds: 8),
    Duration interval = const Duration(milliseconds: 400),
    bool forBackendSync = false,
  }) async {
    final deadline = DateTime.now().add(timeout);
    var firstAttempt = true;
    while (DateTime.now().isBefore(deadline)) {
      final token = await getDeviceToken(
        forBackendSync: forBackendSync && firstAttempt,
      );
      firstAttempt = false;
      if (token != null && token.isNotEmpty) {
        return token;
      }
      await Future.delayed(interval);
    }
    return null;
  }

  /// TODO probably should remove this and track in the DB when apns returns 410, then when user info
  /// is pulled, a bool will determine if its expired and needs to upload a new token.
  /// https://developer.apple.com/forums/thread/682939
  static Future<bool> refreshDeviceTokenIfNeeded({
    Duration minInterval = const Duration(days: 7),
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastChecked = PrefsService.deviceNotificationTokenLastCheckedAt;
    if (lastChecked != null && now - lastChecked < minInterval.inMilliseconds) {
      return false;
    }
    PrefsService.deviceNotificationTokenLastCheckedAt = now;
    final token = await getDeviceToken(forBackendSync: false);
    if (token == null || token.isEmpty) {
      PrefsService.notificationsEnabled = false;
      PrefsService.deviceNotificationToken = null;
      return false;
    }
    final previous = PrefsService.deviceNotificationToken;
    if (previous == token) return false;
    PrefsService.deviceNotificationToken = token;
    return true;
  }

  static Future<void> _handleNavigationPayload(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    debugPrint(data.toString());
    final type = data['data']['type'] as String?;
    debugPrint(type);
    final path = data['data']['path'] as String?;
    if (type == null || path == null) {
      return;
    }
    Eraser.clearAllAppNotifications();
    switch (type) {
      case 'comment':
        context.push('/feed/post/$path');
        break;
      case 'post':
        List<String> parts = path.split('/');
        String lastPart = parts.last;
        context.push('/feed/post/$lastPart').then((value) {
          if (context.mounted) context.go('/feed', extra: true);
        });
        break;
      case 'tag':
        List<String> parts = path.split('/');
        String lastPart = parts.last;
        context.push('/feed/post/$lastPart').then((value) {
          if (context.mounted) context.go('/feed', extra: true);
        });
        break;
      case 'follow':
        context.push('/users/_?uid=$path');
        break;
    }
  }
}

typedef NotificationPayloadHandler =
    Future<void> Function(BuildContext context, Map<String, dynamic> data);

abstract class NotificationPlatformAdapter {
  const NotificationPlatformAdapter();
  bool get registersDuringSetup => true;
  Future<void> initialize();
  Future<void> requestPermissions();
  Future<void> registerDevice();
  Future<String?> getDeviceToken({bool forBackendSync = false});
  void setHandlers(
    BuildContext context,
    void Function() callback,
    NotificationPayloadHandler handler,
  );
}

class NoopNotificationAdapter extends NotificationPlatformAdapter {
  const NoopNotificationAdapter();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> requestPermissions() async {}

  @override
  Future<void> registerDevice() async {}

  @override
  Future<String?> getDeviceToken({bool forBackendSync = false}) async {
    return null;
  }

  @override
  void setHandlers(
    BuildContext context,
    void Function() callback,
    NotificationPayloadHandler handler,
  ) {}
}

class NotificationHandler extends ConsumerStatefulWidget {
  final Widget child;
  const NotificationHandler({super.key, required this.child});

  @override
  ConsumerState<NotificationHandler> createState() =>
      _NotificationHandlerState();
}

class _NotificationHandlerState extends ConsumerState<NotificationHandler> {
  @override
  void initState() {
    if (kIsWeb) {
      return;
    }
    NotificationHelper.setupHandlersWithContext(context, () {
      ref.read(followingFeedProvider.notifier).refresh();
      ref.read(newFeedProvider.notifier).refresh();
      ref.read(popularFeedProvider.notifier).refresh();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
