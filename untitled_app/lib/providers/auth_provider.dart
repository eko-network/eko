import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/interfaces/user.dart';
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
      {required String email,
      required String password,
      required String username,
      required String name,
      required String birthday}) async {
    try {
      final UserCredential user =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (user.user?.uid == null) return 'unknown';
      final userData = {
        'uid': user.user?.uid,
        'email': email,
        'username': username,
        'name': name,
        'fcmTokens': [],
        'blockedUsers': [],
        'isVerified': false,
        'profileData': {
          'birthday': birthday,
          'likedPosts': [],
          'dislikedPosts': [],
          'pollVotes': {},
          'bio': '',
          'followers': [],
          'following': [],
          'likes': 0,
          'dislikes': 0,
          'profilePicture':
              'https://firebasestorage.googleapis.com/v0/b/untitled-2832f.appspot.com/o/profile_pictures%2Fdefault%2Fprofile.jpg?alt=media&token=2543c4eb-f991-468f-9ce8-68c576ffca7c',
        }
      };
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.user?.uid)
          .set(userData);

      await addFCM(user.user!.uid);

      return ('success');
    } on FirebaseAuthException catch (e) {
      return (e.code);
    }
  }

  Future<String> signIn(
      {required String email, required String password}) async {
    try {
      final UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (user.user != null) addFCM(user.user!.uid);
      return ('success');
    } on FirebaseAuthException catch (e) {
      return (e.code);
    }
  }

  Future<void> deleteAccount() async {
    await FirebaseAuth.instance.currentUser?.delete();
  }
}
