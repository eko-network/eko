import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/profile_picture_detail_controller.dart';
import '../custom_widgets/profile_avatar.dart';
import '../utilities/constants.dart' as c;

class ProfilePictureDetail extends StatelessWidget {
  final String imageURL;

  const ProfilePictureDetail({super.key, required this.imageURL});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    return ChangeNotifierProvider(
        create: (context) => ProfilePictureDetailController(context: context),
        builder: (context, child) {
          return InkWell(
            onTap: () => Provider.of<ProfilePictureDetailController>(context,
                    listen: false)
                .backgroundPressed(),
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: double.infinity,
              decoration:
                  BoxDecoration(color: Theme.of(context).colorScheme.shadow),
              child: Hero(
                tag: 'profileImage',
                child: IconButton(
                  onPressed: () {},
                  icon: ProfileAvatar(url: imageURL, size: width * 0.6),
                ),
              ),
            ),
          );
        });
  }
}
