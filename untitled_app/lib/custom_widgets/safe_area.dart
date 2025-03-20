import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled_app/utilities/themes/dark_theme_provider.dart';
import 'package:untitled_app/utilities/constants.dart' as c;

class AppSafeArea extends StatelessWidget {
  const AppSafeArea({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          color: Provider.of<DarkThemeProvider>(context, listen: true).darkTheme
              ? c.darkThemeColors(context).surface
              : c.lightThemeColors(context).surface),
      child: SafeArea(
        child: child,
      ),
    );
  }
}
