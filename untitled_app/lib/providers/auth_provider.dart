import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/models/shared_pref_model.dart';
import 'package:untitled_app/types/auth.dart';
// Necessary for code-generation to work
part '../generated/providers/auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AuthModel build() {
    _init();
    return AuthModel.loading();
  }

  void _init() {
    // TODO This should also handle presence
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        state = AuthModel.signedOut();
      } else {
        state =
            state.copyWith(uid: user.uid, isLoading: false, email: user.email);
      }
    });
  }

  Future<String> signUp(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return ('success');
    } on FirebaseAuthException catch (e) {
      return (e.code);
    }
  }

  Future<String> signIn(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return ('success');
    } on FirebaseAuthException catch (e) {
      return (e.code);
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

  // I copied this. Didn't change anything
  Future<void> addFCM() async {
    if (!kIsWeb && state.uid != null) {
      // TODO: eventually needs to support timestamp
      final DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(state.uid);

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
}
