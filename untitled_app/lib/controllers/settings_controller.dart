import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/models/shared_pref_model.dart';
import 'package:untitled_app/utilities/locator.dart';
import 'package:go_router/go_router.dart';
import '../custom_widgets/warning_dialog.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';

class SettingsController extends ChangeNotifier {
  final BuildContext context;
  bool activityNotification = true;

  SettingsController({
    required this.context,
  }) {
    init();
  }
  init() async {
    activityNotification = getActivityNotification();
    notifyListeners();
  }

  void _popDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _delete() async {
    _popDialog();
    try {
      await locator<CurrentUser>().deleteAccount();
      // locator<NavBarController>().enable();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        context.pushNamed('re_auth');
      }
    }
  }

  toggleActivityNotification(value) async {
    setActivityNotification(value);
    if (value) {
      locator<CurrentUser>().addFCM();
      activityNotification = true;
    } else {
      locator<CurrentUser>().removeFCM();
      activityNotification = false;
    }

    notifyListeners();
  }

  void blockedPressed() {
    context.pushNamed('blocked_users');
  }

  signOut() async {
    await locator<CurrentUser>().signOut();
    // locator<NavBarController>().enable();
  }

  deleteAccount() {
    showMyDialog(
        AppLocalizations.of(context)!.deleteAcountTitle,
        AppLocalizations.of(context)!.deleteAcountBody,
        [
          AppLocalizations.of(context)!.goBack,
          AppLocalizations.of(context)!.delete
        ],
        [_popDialog, _delete],
        context);
  }
}
