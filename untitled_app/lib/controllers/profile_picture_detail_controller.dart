import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilePictureDetailController extends ChangeNotifier {
  final BuildContext context;
  ProfilePictureDetailController({required this.context});
  void backgroundPressed() {
    // locator<NavBarController>().enable();
    context.pop();
  }
}
