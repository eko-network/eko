import 'package:untitled_app/custom_widgets/login_text_feild.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';

import '../models/current_user.dart';
import 'package:flutter/material.dart';
import '../custom_widgets/warning_dialog.dart';
import '../utilities/locator.dart';
import "package:go_router/go_router.dart";

class LoginController extends ChangeNotifier {
  // BuildContext context;
  // LoginController(this.context);

  bool loggingIn = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final resetEmailController = TextEditingController();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final resetEmailFocus = FocusNode();

  final BuildContext context;

  LoginController({required this.context});

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    resetEmailController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    resetEmailFocus.dispose();
    super.dispose();
  }

  void _pop() {
    Navigator.of(context).pop();
  }

  void _popDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _signUpFromAlert() {
    _pop();
    signUp();
  }

  void signUp() {
    hideKeyboard();
    context.go("/signup");
  }

  void previousPressed() {
    hideKeyboard();
    context.go("/");
    // Provider.of<DarkThemeProvider>(context, listen: false).toggleWelcome(true);
  }

  void forgotPasswordPressed(countryCode) {
    hideKeyboard();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(AppLocalizations.of(context)!.resetPassword),
          content: SingleChildScrollView(
            child: CustomInputFeild(
              focus: resetEmailFocus,
              label: AppLocalizations.of(context)!.email,
              controller: resetEmailController,
              inputType: TextInputType.emailAddress,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                _pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.sendResetLink),
              onPressed: () {
                resetPassword(countryCode);
              },
            ),
          ],
        );
      },
    );
  }

  resetPassword(countryCode) async {
    _pop();
    hideKeyboard();
    locator<CurrentUser>().email = resetEmailController.text.trim();
    if (_handleError(
            await locator<CurrentUser>().forgotPassword(countryCode)) ==
        0) {
      resetConfirmation();
    }
  }

  resetConfirmation() {
    showMyDialog(
        AppLocalizations.of(context)!.forgotPasswordTittle,
        AppLocalizations.of(context)!.forgotPasswordBody,
        [AppLocalizations.of(context)!.ok],
        [_pop],
        context);
  }

  logInPressed() async {
    hideKeyboard();
    if (emailController.text == '') {
      emailFocus.requestFocus();
    } else if (passwordController.text == '') {
      passwordFocus.requestFocus();
    } else {
      locator<CurrentUser>().email = emailController.text;
      loggingIn = true;
      notifyListeners();

      if (_handleError(
              await locator<CurrentUser>().signIn(passwordController.text)) ==
          0) {
        locator<CurrentUser>().addFCM();
      }

      loggingIn = false;
      notifyListeners(); //FIXME problems can apear here since it gets disposed
    }
  }

  int _handleError(String errorCode) {
    int errorStatus;
    switch (errorCode) {
      case 'success':
        errorStatus = 0;
        break;
      case 'invalid-email':
        showMyDialog(
            AppLocalizations.of(context)!.invalidEmailTittle,
            AppLocalizations.of(context)!.invalidEmailBody,
            [AppLocalizations.of(context)!.tryAgain],
            [_popDialog],
            context);
        errorStatus = 1;
        break;
      case 'user-not-found':
        showMyDialog(
            AppLocalizations.of(context)!.userNotFoundTitle,
            AppLocalizations.of(context)!.userNotFoundBody,
            [
              AppLocalizations.of(context)!.signUp,
              AppLocalizations.of(context)!.tryAgain
            ],
            [_signUpFromAlert, _pop],
            context);
        errorStatus = 2;
        break;
      case 'wrong-password':
        showMyDialog(
            AppLocalizations.of(context)!.wrongPasswordTittle,
            AppLocalizations.of(context)!.wrongPasswordBody,
            [AppLocalizations.of(context)!.tryAgain],
            [_pop],
            context);
        errorStatus = 3;
        break;
      case 'user-disabled':
        showMyDialog(
            AppLocalizations.of(context)!.userDisabledTittle,
            AppLocalizations.of(context)!.userDisabledBody,
            [AppLocalizations.of(context)!.tryAgain],
            [_pop],
            context);
        errorStatus = 4;
        break;
      default:
        showMyDialog(
            AppLocalizations.of(context)!.defaultErrorTittle,
            AppLocalizations.of(context)!.defaultErrorBody,
            [AppLocalizations.of(context)!.tryAgain],
            [_pop],
            context);
        errorStatus = -1;
        break;
    }
    return errorStatus;
  }
}
