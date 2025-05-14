import 'package:flutter/material.dart';
import 'package:untitled_app/utilities/constants.dart' as c;

class StyledDivider extends StatelessWidget {
  const StyledDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Theme.of(context).colorScheme.outline,
      height: c.dividerWidth,
    );
  }
}
