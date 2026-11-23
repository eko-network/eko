import 'package:material_ui/material_ui.dart';
import 'package:eko_app/utilities/constants.dart' as c;

/// Standard auth button with consistent styling
/// Use [AuthButtonType.primary] for main CTAs
/// Use [AuthButtonType.secondary] for alternative actions
/// Use [AuthButtonType.tertiary] for low-priority actions
enum AuthButtonType { primary, secondary, tertiary }

class AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AuthButtonType type;
  final bool isLoading;
  final double? width;

  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AuthButtonType.primary,
    this.isLoading = false,
    this.width,
  });

  const AuthButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.width,
  }) : type = AuthButtonType.primary;

  const AuthButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.width,
  }) : type = AuthButtonType.secondary;

  const AuthButton.tertiary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.width,
  }) : type = AuthButtonType.tertiary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonWidth = width ?? c.widthGetter(context) * 0.9;

    Widget buttonChild;
    if (isLoading) {
      buttonChild = SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: type == AuthButtonType.primary
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
        ),
      );
    } else {
      buttonChild = Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: _getTextColor(theme),
        ),
      );
    }

    return SizedBox(
      width: buttonWidth,
      height: c.authButtonHeight,
      child: _buildButton(theme, buttonChild),
    );
  }

  Widget _buildButton(ThemeData theme, Widget child) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    switch (type) {
      case AuthButtonType.primary:
        return FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: child,
        );
      case AuthButtonType.secondary:
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: theme.colorScheme.outline),
            foregroundColor: theme.colorScheme.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: child,
        );
      case AuthButtonType.tertiary:
        return TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface,
          ),
          child: child,
        );
    }
  }

  Color _getTextColor(ThemeData theme) {
    switch (type) {
      case AuthButtonType.primary:
        return theme.colorScheme.onPrimary;
      case AuthButtonType.secondary:
      case AuthButtonType.tertiary:
        return theme.colorScheme.onSurface;
    }
  }
}
