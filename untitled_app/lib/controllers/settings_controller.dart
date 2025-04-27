import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as prov;
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/models/shared_pref_model.dart';
import 'package:untitled_app/utilities/locator.dart';
import '../utilities/themes/dark_theme_provider.dart';
import '../controllers/bottom_nav_bar_controller.dart';
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
    activityNotification = await getActivityNotification();
    notifyListeners();
  }

  bool getThemeValue() {
    return prov.Provider.of<DarkThemeProvider>(context, listen: false)
        .darkTheme;
  }

  changeValue(value) {
    final themeChange =
        prov.Provider.of<DarkThemeProvider>(context, listen: false);
    themeChange.darkTheme = value;
  }

  void _popDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _delete() async {
    _popDialog();
    try {
      await locator<CurrentUser>().deleteAccount();
      locator<NavBarController>().enable();
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
    locator<NavBarController>().enable();
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
