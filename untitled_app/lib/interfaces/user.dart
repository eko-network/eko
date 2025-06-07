import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:untitled_app/models/shared_pref_model.dart';
import '../utilities/constants.dart' as c;

Future<bool> isUsernameAvailable(String username) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('username', isEqualTo: username)
      .get();

  if (querySnapshot.docs.isEmpty) {
    return true;
  } else {
    return false;
  }
}

bool isUsernameValid(String username) {
  return username.trim().contains(RegExp(c.userNameReqs));
}

// I copied this. Didn't change anything
Future<void> addFCM(String uid) async {
  if (!kIsWeb) {
    // TODO: eventually needs to support timestamp
    final DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(uid);
    try {
      // Get the current data
      final DocumentSnapshot userSnapshot = await userDocRef.get();
      if (userSnapshot.exists) {
        final String currentDeviceToken =
            await FirebaseMessaging.instance.getToken() ?? '';
        // Retrieve the FCM tokens array
        // TODO: will change when in a collection
        if (userSnapshot.data().toString().contains('fcmTokens')) {
          List<String> fcmTokens =
              List<String>.from(userSnapshot['fcmTokens'] ?? []);

          // check to see if contained in array
          if (!fcmTokens.contains(currentDeviceToken)) {
            fcmTokens.add(currentDeviceToken);
          }
          // Update the Firestore document with the modified FCM tokens array
          await userDocRef.update({'fcmTokens': fcmTokens});
        } else {
          List<String> fcmTokens = [];
          fcmTokens.add(currentDeviceToken);
          userDocRef.update({'fcmTokens': fcmTokens});
        }
        setActivityNotification(true);
      }
    } catch (e) {
      // TODO: Handle the error as needed
    }
  }
}

Future<String> forgotPassword(
    {required String? countryCode, required String email}) async {
  await FirebaseAuth.instance.setLanguageCode(countryCode);
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    return ('success');
  } on FirebaseAuthException catch (e) {
    return (e.code);
  }
}

Future<String?> getUidFromUsername(String username) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('username', isEqualTo: username)
      .get();
  if (querySnapshot.docs.isEmpty) {
    return null;
  } else {
    return querySnapshot.docs.first.id;
  }
}

Future<String> verifyPasswordReset(String code) async {
  try {
    return await FirebaseAuth.instance.verifyPasswordResetCode(code);
  } on FirebaseAuthException {
    rethrow;
  }
}

Future<String> resetPassword(String code, String password) async {
  try {
    await FirebaseAuth.instance
        .confirmPasswordReset(code: code, newPassword: password);
    return 'success';
  } on FirebaseAuthException catch (e) {
    return (e.code);
  }
}
