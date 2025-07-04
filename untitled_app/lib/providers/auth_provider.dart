import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' show debugPrint;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState;
import 'package:untitled_app/types/auth.dart';
import 'package:untitled_app/utilities/supabase_ref.dart';
// Necessary for code-generation to work
part '../generated/providers/auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  StreamSubscription<AuthState>? _authSubscription;
  @override
  AuthModel build() {
    _init();
    ref.onDispose(() {
      _authSubscription?.cancel();
    });
    return AuthModel.loading();
  }

  void _init() {
    _authSubscription = supabase.auth.onAuthStateChange.listen((_) {
      final user = supabase.auth.currentUser;
      if (user == null) {
        state = AuthModel.signedOut();
      } else {
        state =
            state.copyWith(uid: user.id, isLoading: false, email: user.email);
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
      await supabase.auth
          .signUp(email: email.trim(), password: password, data: {
        'username': username,
        'name': name,
        'birthday': birthday,
      });

      // await addFCM(user.user!.uid);

      return ('success');
    } catch (e) {
      debugPrint(e.toString());
      return (e.toString());
    }
  }

  Future<String> signIn(
      {required String email, required String password}) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // if (user.user != null) addFCM(user.user!.uid);
      return ('success');
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      return (e.code);
    }
  }

  Future<void> deleteAccount() async {
    // await supabase.auth.();
  }
}
