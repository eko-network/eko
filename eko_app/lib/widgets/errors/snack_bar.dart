import 'package:flutter/material.dart';

enum SnackBarVariant { primary, destructive }

void showSnackBar({
  String text = '',
  int time = 3000,
  required BuildContext context,
  SnackBarVariant variant = SnackBarVariant.primary,
}) {
  final mediaQuery = MediaQuery.of(context);
  final screenWidth = mediaQuery.size.width;
  final bottomPadding = mediaQuery.padding.bottom;

  const maxSnackBarWidth = 420.0;
  const minMargin = 16.0;
  final horizontalMargin = screenWidth > maxSnackBarWidth
      ? (screenWidth - maxSnackBarWidth) / 2
      : minMargin;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: _ToastContent(
        text: text,
        variant: variant,
        onDismiss: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
      duration: Duration(milliseconds: time),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: bottomPadding + 16,
        right: horizontalMargin,
        left: horizontalMargin,
      ),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      dismissDirection: DismissDirection.down,
    ),
  );
}

class _ToastContent extends StatefulWidget {
  const _ToastContent({
    required this.text,
    required this.variant,
    required this.onDismiss,
  });

  final String text;
  final SnackBarVariant variant;
  final VoidCallback onDismiss;

  @override
  State<_ToastContent> createState() => _ToastContentState();
}

class _ToastContentState extends State<_ToastContent>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final backgroundColor = widget.variant == SnackBarVariant.destructive
        ? colorScheme.errorContainer
        : colorScheme.surface;

    final textColor = widget.variant == SnackBarVariant.destructive
        ? colorScheme.onErrorContainer
        : colorScheme.onSurface;

    return SlideTransition(
      position: _slideAnimation,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          constraints: const BoxConstraints(minWidth: 300, maxWidth: 420),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: widget.variant == SnackBarVariant.destructive
                ? null
                : Border.all(color: colorScheme.outline, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedOpacity(
                  opacity: _isHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onDismiss,
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: textColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
