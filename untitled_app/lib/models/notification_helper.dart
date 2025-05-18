import 'package:eraser/eraser.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/providers/following_feed_provider.dart';
import 'package:untitled_app/providers/new_feed_provider.dart';
// import 'package:untitled_app/firebase_options.dart';

class NotificationHelper {
  static Future<void> setupNotifications() async {
    if (!kIsWeb) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      await Future.wait([
        FirebaseMessaging.instance.setAutoInitEnabled(true),
        messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        ),
        FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: false,
          badge: false,
          sound: false,
        )
      ]);
    }
  }

  static void setupNotificationsWithContext(
      BuildContext context, void Function() callback) {
    Future<void> onNotification(
        BuildContext context, RemoteMessage message) async {
      String path = message.data['path'];
      String type = message.data['type'];
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
          context.push('/feed/sub_profile/$path');
          break;
      }
    }

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        if (context.mounted) onNotification(context, message);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (context.mounted) onNotification(context, message);
      callback();
    });
  }

  static Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // await Firebase.initializeApp(
    //     options: DefaultFirebaseOptions.currentPlatform);
  }
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
    NotificationHelper.setupNotificationsWithContext(context, () {
      ref.read(followingFeedProvider.notifier).refresh();
      ref.read(newFeedProvider.notifier).refresh();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
