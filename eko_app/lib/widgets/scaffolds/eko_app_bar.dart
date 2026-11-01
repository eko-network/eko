import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EkoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EkoAppBar({
    super.key,
    this.title,
    this.actions = const [],
    this.onBack,
    this.showBackButton = true,
    this.backgroundColor,
    this.elevation = 0,
    this.scrolledUnderElevation = 0,
    this.surfaceTintColor = Colors.transparent,
    this.titleSpacing,
    this.bottom,
  });

  final Widget? title;
  final List<Widget> actions;
  final VoidCallback? onBack;
  final bool showBackButton;
  final Color? backgroundColor;
  final double elevation;
  final double? scrolledUnderElevation;
  final Color? surfaceTintColor;
  final double? titleSpacing;
  final PreferredSizeWidget? bottom;

  static TextStyle titleTextStyle(BuildContext context) => TextStyle(
    fontWeight: FontWeight.normal,
    color: Theme.of(context).colorScheme.onSurface,
  );

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    final Widget? resolvedLeading = showBackButton
        ? IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: onBack ?? () => context.pop(),
          )
        : null;

    final Widget? titleWidget = title == null
        ? null
        : DefaultTextStyle.merge(style: titleTextStyle(context), child: title!);

    return AppBar(
      leading: resolvedLeading,
      automaticallyImplyLeading: false,
      titleSpacing: titleSpacing,
      title: titleWidget,
      actions: actions,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      surfaceTintColor: surfaceTintColor,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      bottom: bottom,
    );
  }
}
