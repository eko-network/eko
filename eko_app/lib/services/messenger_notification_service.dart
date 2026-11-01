import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MessengerNotificationService {
  static final MessengerNotificationService _instance =
      MessengerNotificationService._internal();
  factory MessengerNotificationService() => _instance;
  MessengerNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;

    requestPermissions();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  Future<void> showNewMessageNotification({
    required String from,
    required String message,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'eko_messages',
        'Messages',
        channelDescription: 'New message notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
    );

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: from,
      body: message,
      notificationDetails: details,
    );
  }
}
