import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/utilities/locator.dart';
import '../custom_widgets/warning_dialog.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';

enum Page {
  loading,
  invalid,
  resetPassword,
}

class AuthActionInterfaceController extends ChangeNotifier {
  final BuildContext context;
  final Map<String, String> urlData;
  final pageController = PageController(initialPage: Page.loading.index);
  List<String> passed = ['❌', '❌', '❌', '❌', '❌', '❌'];
  bool goodPassword = false;
  double passwordPercent = 0;
  late String userEmail;
  final passwordFocus = FocusNode();
  final passwordConfirmFocus = FocusNode();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  bool loggingIn = false;
  AuthActionInterfaceController(
      {required this.context, required this.urlData}) {
    _init();
  }

  @override
  void dispose() {
    passwordFocus.dispose();
    passwordConfirmFocus.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }

  void _init() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if ((urlData['mode'] ?? '') == 'resetPassword') {
        try {
          userEmail = await locator<CurrentUser>()
              .verifyPasswordReset(urlData['oobCode'] ?? '');
          pageController.jumpToPage(Page.resetPassword.index);
        } on FirebaseAuthException {
          //Handle later
          pageController.jumpToPage(Page.invalid.index);
        }
      } else {
        pageController.jumpToPage(Page.invalid.index);
      }
    });
  }

  void _pop() {
    context.pop();
  }

  void _popDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _popTwice() {
    _pop();
    context.go('/');
  }

  void _popAndGo() {
    _pop();
    context.go('/login');
  }

  void exitOnPagePressed() {
    context.go('/');
  }

  void showExitWarning() {
    showMyDialog(
        AppLocalizations.of(context)!.exitEditProfileTitle,
        '',
        [
          AppLocalizations.of(context)!.exit,
          AppLocalizations.of(context)!.stay
        ],
        [_popTwice, _popDialog],
        context);
  }

  void backPressed({bool? didPop}) {
    didPop ??= false;
    if (pageController.page == Page.invalid.index && !didPop) {
      _pop();
    } else if (pageController.page == Page.resetPassword.index) {
      showExitWarning();
    }
  }

  void _goToLogin() {
    showMyDialog(
        AppLocalizations.of(context)!.passwordResetTitle,
        AppLocalizations.of(context)!.passwordResetBody,
        [AppLocalizations.of(context)!.ok],
        [_popAndGo],
        context);
  }

  bool _handleError(String errorCode) {
    switch (errorCode) {
      case 'success':
        return true;
      case 'weak-password':
        showMyDialog(
            AppLocalizations.of(context)!.weakPasswordTitle,
            AppLocalizations.of(context)!.weakPasswordBody,
            [AppLocalizations.of(context)!.tryAgain],
            [_popDialog],
            context);
        break;
      default:
        break;
    }
    return false;
  }

  passwordChanged() {
    passed = ['❌', '❌', '❌', '❌', '❌', '❌'];
    int points = 0;
    String pass1 = passwordController.text;
    String pass2 = passwordConfirmController.text;
    if ((pass1).length >= 7 && (pass1).length <= 32) {
      points++;
      passed[0] = '✅';
    }
    if (pass1.contains(RegExp(r'[a-z]'))) {
      points++;
      passed[1] = '✅';
    }
    if (pass1.contains(RegExp(r'[A-Z]'))) {
      points++;
      passed[2] = '✅';
    }

    if (pass1.contains(RegExp(r'[0-9]'))) {
      points++;
      passed[3] = '✅';
    }
    if (!pass1.contains(RegExp(r'^[A-Za-z0-9]*$'))) {
      points++;
      passed[4] = '✅';
    }
    if (pass1 == pass2 && pass1 != '') {
      points++;
      passed[5] = '✅';
    }
    goodPassword = (points == 6);
    if (pass1 != '') {
      passwordPercent = points / 6;
    } else {
      passwordPercent = 0;
    }
    notifyListeners();
  }

  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  setPasswordPressed() async {
    hideKeyboard();

    if (passwordController.text == '') {
      passwordFocus.requestFocus();
    } else {
      //TODO delete || controller2.text == "password" before production
      if (goodPassword) {
        loggingIn = true;
        notifyListeners();

        if (_handleError(
          await locator<CurrentUser>()
              .resetPassword(urlData['oobCode'] ?? '', passwordController.text),
        )) {
          _goToLogin();
        } else {
          passwordController.text = '';
          passwordConfirmController.text = '';
          passed = ['❌', '❌', '❌', '❌', '❌', '❌'];
          pageController.jumpToPage(Page.invalid.index);
        }

        loggingIn = false;
        notifyListeners();
      } else {
        _handleError('weak-password');
      }
    }
  }
}
