import 'package:material_ui/material_ui.dart';

/// Simple horizontal line divider for auth forms
/// Used to separate sections (e.g., before social auth buttons)
class AuthDivider extends StatelessWidget {
  final double indent;
  final double endIndent;

  const AuthDivider({super.key, this.indent = 0, this.endIndent = 0});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Theme.of(context).colorScheme.outline,
      indent: indent,
      endIndent: endIndent,
    );
  }
}
