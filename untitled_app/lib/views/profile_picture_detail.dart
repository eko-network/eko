import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/widgets/profile_picture.dart';
import '../utilities/constants.dart' as c;

class ProfilePictureDetail extends StatelessWidget {
  final String uid;

  const ProfilePictureDetail({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    return Scaffold(
      body: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: double.infinity,
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.shadow),
            child: ProfilePicture(
              uid: uid,
              size: width * 0.75,
              onlineIndicatorEnabled: false,
            )),
      ),
    );
  }
}
