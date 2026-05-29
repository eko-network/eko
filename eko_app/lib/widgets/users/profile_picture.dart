import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/widgets/loading/profile_picture_loading.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/widgets/users/network_or_default_profile_image.dart';

class ProfilePicture extends ConsumerWidget {
  final String uid;
  final bool onlineIndicatorEnabled;
  final void Function()? onPressed;
  final EdgeInsets? padding;
  final double size;
  const ProfilePicture({
    required this.uid,
    this.onlineIndicatorEnabled = true,
    this.onPressed,
    this.padding,
    required this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(userProvider(uid));
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(0),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              ClipOval(
                child: asyncUser.when(
                  data: (user) {
                    return NetworkOrDefaultProfileImage(
                      imageUrl: user.profilePicture,
                    );
                  },
                  error: (_, _) {
                    return Text(AppLocalizations.of(context)!.shortLoadError);
                  },
                  loading: () => LoadingProfileImage(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfilePictureFromFile extends StatelessWidget {
  final void Function()? onPressed;
  final EdgeInsets? padding;
  final double size;
  final File file;
  const ProfilePictureFromFile({
    this.onPressed,
    this.padding,
    required this.size,
    required this.file,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(0),
        child: SizedBox(
          width: size,
          height: size,
          child: ClipOval(child: Image.file(file, fit: BoxFit.cover)),
        ),
      ),
    );
  }
}
