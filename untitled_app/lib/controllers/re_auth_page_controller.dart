import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/warning_dialog.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/utilities/locator.dart';

class ReAuthPageController extends ChangeNotifier {
  final BuildContext context;
  final passwordController = TextEditingController();
  final passwordFocus = FocusNode();
  bool isLoading = false;
  ReAuthPageController({required this.context});

  @override
  void dispose() {
    passwordController.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  void buttonTap() async {
    if (!isLoading) {
      isLoading = true;
      notifyListeners();
      final password = passwordController.text;
      if (password == '') {
        passwordFocus.requestFocus();
      } else {
        if (_handleError(await locator<CurrentUser>().signIn(password)) == 0) {
          locator<CurrentUser>().deleteAccount();
        }
      }
      isLoading = false;
      notifyListeners();
    }
  }

  void _pop() {
    context.pop();
  }

  void _popDialog() {
    Navigator.of(context, rootNavigator: true).pop();
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

      case 'wrong-password':
        showMyDialog(
            AppLocalizations.of(context)!.wrongPasswordTittle,
            AppLocalizations.of(context)!.wrongPasswordBody,
            [AppLocalizations.of(context)!.tryAgain],
            [_popDialog],
            context);
        errorStatus = 3;
        break;
      case 'user-disabled':
        showMyDialog(
            AppLocalizations.of(context)!.userDisabledTittle,
            AppLocalizations.of(context)!.userDisabledBody,
            [AppLocalizations.of(context)!.tryAgain],
            [_popDialog],
            context);
        errorStatus = 4;
        break;
      default:
        showMyDialog(
            AppLocalizations.of(context)!.defaultErrorTittle,
            AppLocalizations.of(context)!.defaultErrorBody,
            [AppLocalizations.of(context)!.tryAgain],
            [_popDialog],
            context);
        errorStatus = -1;
        break;
    }
    return errorStatus;
  }
}
