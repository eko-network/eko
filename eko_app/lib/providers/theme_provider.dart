import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eko_app/utilities/constants.dart';
import 'package:eko_app/utilities/shared_pref_service.dart';

part '../generated/providers/theme_provider.g.dart';

@Riverpod(keepAlive: true)
class ColorTheme extends _$ColorTheme {
  @override
  ColorScheme build() {
    final isDarkTheme = PrefsService.isDarkMode;
    return isDarkTheme ? darkThemeColors : lightThemeColors;
  }

  void changeTheme(bool isDarkTheme) {
    PrefsService.isDarkMode = isDarkTheme;
    state = isDarkTheme ? darkThemeColors : lightThemeColors;
  }
}
