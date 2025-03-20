import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/controllers/bottom_nav_bar_controller.dart';
import 'package:untitled_app/controllers/feed_controller.dart';
import 'package:untitled_app/models/feed_post_cache.dart';
import 'package:untitled_app/utilities/locator.dart';

class NotificationService extends ChangeNotifier {
  NotificationService() {
    initializeNotification();
  }

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'high_importance_channel',
    description: 'description',
    importance: Importance.max,
    playSound: true,
  );

  static NotificationDetails _notificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  static Future<void> initializeNotification() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    await _notificationsPlugin.initialize(
      const InitializationSettings(
          android: androidInitializationSettings,
          iOS: DarwinInitializationSettings()),
    );
  }

  // static void onMessage(RemoteMessage message) {
  //   // Extract custom data from the FCM message
  //   RemoteNotification? notification = message.notification;
  //   AndroidNotification? androidNotification = message.notification?.android;
  //   AppleNotification? appleNotification = message.notification?.apple;
  //   if (notification == null) return;
  //   if (androidNotification != null || appleNotification != null) {
  //     _notificationsPlugin.show(
  //       notification.hashCode,
  //       notification.title,
  //       notification.body,
  //       _notificationDetails(),
  //     );
  //   }
  // }
  static Future<void> onMessage(
      RemoteMessage message, BuildContext context) async {
    // Extract custom data from the FCM message
    RemoteNotification? notification = message.notification;
    AndroidNotification? androidNotification = message.notification?.android;
    AppleNotification? appleNotification = message.notification?.apple;

    if (androidNotification != null || appleNotification != null) {
      // Show in-app overlay notification
      showOverlayNote(context, message);
    }
  }

  static void onMessageOpenedApp(BuildContext context, RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? androidNotification = message.notification?.android;
    AppleNotification? appleNotification = message.notification?.apple;

    if (notification == null) return;
    if (androidNotification != null || appleNotification != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(notification.title ?? 'No Title'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.body ?? 'No body'),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> postNotification(
      BuildContext context, RemoteMessage message) async {
    String path = message.data['path'];
    String type = message.data['type'];
    locator<FeedPostCache>().clearFeedCache();
    // await locator<PostsHandling>().getFeedPosts(
    //     null,
    //     FirebaseFirestore.instance
    //         .collection("posts")
    //         .orderBy('time', descending: true));
    cancelNotification();
    switch (type) {
      case 'comment':
        context.push("/feed/post/$path");
        break;
      case 'post':
        List<String> parts = path.split('/');
        String lastPart = parts.last;
        context.push("/feed/post/$lastPart").then((value) {
          context.go("/feed", extra: true);
        });
        break;
      case 'tag':
        List<String> parts = path.split('/');
        String lastPart = parts.last;
        context.push("/feed/post/$lastPart").then((value) {
          context.go("/feed", extra: true);
        });
        locator<NavBarController>().enable();
        break;
      case 'follow':
        context.push("/feed/sub_profile/$path");
        break;
    }
  }

  Future<void> inAppPostNotification(
      BuildContext context, RemoteMessage message) async {
    String path = message.data['path'];
    String type = message.data['type'];
    locator<FeedPostCache>().clearFeedCache();
    // await locator<PostsHandling>().getFeedPosts(
    //     null,
    //     FirebaseFirestore.instance
    //         .collection("posts")
    //         .orderBy('time', descending: true),
    //     2);
    switch (type) {
      case 'comment':
        context.push("/feed/post/$path");
        break;
      case 'post':
        List<String> parts = path.split('/');
        String lastPart = parts.last;
        context.push("/feed/post/$lastPart");
        break;
      case 'tag':
        List<String> parts = path.split('/');
        String lastPart = parts.last;
        context.push("/feed/post/$lastPart");
        locator<NavBarController>().enable();
        break;
    }
    locator<NavBarController>().enable();
  }

  static Future<void> cancelNotification() async {
    await _notificationsPlugin.cancelAll();
  }
}
