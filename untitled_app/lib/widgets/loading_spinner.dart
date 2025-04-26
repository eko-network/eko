import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../utilities/constants.dart' as c;

class LoadingSpinner extends StatelessWidget {
  final double? width;
  const LoadingSpinner({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    c.widthGetter(context);
    return SizedBox(
      width: width ?? (c.widthGetter(context) * 0.2),
      child: LoadingIndicator(
        indicatorType: Indicator.ballSpinFadeLoader,
        colors: [Theme.of(context).colorScheme.primary],
      ),
    );
  }
}
