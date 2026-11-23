import 'package:material_ui/material_ui.dart';
import 'package:eko_app/utilities/constants.dart' as c;

class MaxWidthContent extends StatelessWidget {
  const MaxWidthContent({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: c.indealAppWidth),
        child: child,
      ),
    );
  }
}
