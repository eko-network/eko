import 'package:flutter/material.dart';
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/utilities/locator.dart';
import '../themes/dark_theme_preference.dart';

class DarkThemeProvider with ChangeNotifier {
  DarkThemePreference darkThemePreference = DarkThemePreference();
  bool onWelcomePage = false;
  bool _darkTheme = true;

  DarkThemeProvider() {
    _loadDarkThemeFromPrefs(); // Initialize _darkTheme during construction
    if (locator<CurrentUser>().getUID() == '') {
      onWelcomePage = true;
    }
  }

  bool get darkTheme => _darkTheme;

  set darkTheme(bool value) {
    _darkTheme = value;
    darkThemePreference.setDarkTheme(value);
    notifyListeners();
  }

  Future<void> _loadDarkThemeFromPrefs() async {
    _darkTheme = await darkThemePreference.getTheme();
    notifyListeners();
  }
}
