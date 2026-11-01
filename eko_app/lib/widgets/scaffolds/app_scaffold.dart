import 'package:flutter/material.dart';
import 'package:eko_app/widgets/common/max_width_content.dart';

class MaxWidthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MaxWidthAppBar({super.key, required this.child});
  final PreferredSizeWidget child;

  @override
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(BuildContext context) {
    return MaxWidthContent(child: child);
  }
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.contrainBody = false,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool contrainBody;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar == null ? null : MaxWidthAppBar(child: appBar!),
      body: contrainBody ? MaxWidthContent(child: body) : body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
