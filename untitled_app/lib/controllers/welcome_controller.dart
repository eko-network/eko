import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeController extends ChangeNotifier {
  final BuildContext context;

  WelcomeController({required this.context});

  void goToLogin() {
    (context).push('/login');
  }

  void goToSignUp() {
    (context).push('/signup');
  }
}
