import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/types/auth.dart';
// Necessary for code-generation to work
part '../generated/riverpod_providers/auth_provider.g.dart';

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
}
