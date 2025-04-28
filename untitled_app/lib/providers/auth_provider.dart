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
      final UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (user.user != null) addFCM(user.user!.uid);
      return ('success');
    } on FirebaseAuthException catch (e) {
      return (e.code);
    }
  }
}
