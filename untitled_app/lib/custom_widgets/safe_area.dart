import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/providers/theme_provider.dart';

class AppSafeArea extends ConsumerWidget {
  const AppSafeArea({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DecoratedBox(
      decoration: BoxDecoration(color: ref.watch(colorThemeProvider).surface),
      child: SafeArea(
        child: child,
      ),
    );
  }
}
