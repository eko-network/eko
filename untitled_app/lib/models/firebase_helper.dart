// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:untitled_app/firebase_options.dart';

class FirebaseHelper {
  const FirebaseHelper._();

  // static final FirebaseAuth _auth = FirebaseAuth.instance;
  // static final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  static Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }
}
