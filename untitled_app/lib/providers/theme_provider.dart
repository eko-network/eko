import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/utilities/constants.dart';
import 'package:untitled_app/utilities/shared_pref_service.dart';

part '../generated/providers/theme_provider.g.dart';

const String key = 'THEMESTATUS';

@Riverpod(keepAlive: true)
class ColorTheme extends _$ColorTheme {
  @override
  ColorScheme build() {
    final prefs = PrefsService.instance;
    final isDarkTheme = prefs.getBool(key) ?? true;
    return isDarkTheme ? darkThemeColors : lightThemeColors;
  }

  void changeTheme(bool isDarkTheme) {
    PrefsService.instance.setBool(key, isDarkTheme);
    state = isDarkTheme ? darkThemeColors : lightThemeColors;
  }
}
