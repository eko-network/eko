import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AlwaysOriented extends StatefulWidget {
  final Widget child;
  final DeviceOrientation orientation;

  const AlwaysOriented({
    super.key,
    required this.child,
    required this.orientation,
  });

  @override
  State<AlwaysOriented> createState() => _AlwaysOrientedState();
}

class _AlwaysOrientedState extends State<AlwaysOriented> {
  late double _angle;

  @override
  void initState() {
    super.initState();
    _angle = _angleFromOrientation(widget.orientation);
  }

  @override
  void didUpdateWidget(covariant AlwaysOriented oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orientation != widget.orientation) {
      setState(() {
        _angle = _angleFromOrientation(widget.orientation);
      });
    }
  }

  double _angleFromOrientation(DeviceOrientation orientation) {
    switch (orientation) {
      case DeviceOrientation.portraitUp:
        return 0;
      case DeviceOrientation.landscapeLeft:
        return math.pi / 2;
      case DeviceOrientation.portraitDown:
        return math.pi;
      case DeviceOrientation.landscapeRight:
        return -math.pi / 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: _angle),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, angle, child) {
        return Transform.rotate(
          angle: angle,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
