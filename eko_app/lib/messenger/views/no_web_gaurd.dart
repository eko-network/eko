import 'package:eko_app/utilities/platform.dart' as platform;
import 'package:flutter/material.dart';

class NoMessagesForWeb extends StatelessWidget {
  final Widget child;
  const NoMessagesForWeb({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    //TODO
    return platform.isWeb ? Placeholder() : child;
  }
}
