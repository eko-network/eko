import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/custom_widgets/profile_picture_loading.dart';
import 'package:untitled_app/providers/user_provider.dart';

class ProfilePicture extends ConsumerWidget {
  final String uid;
  final void Function()? onPressed;
  final EdgeInsets? padding;
  final double size;
  const ProfilePicture(
      {required this.uid,
      this.onPressed,
      this.padding,
      required this.size,
      super.key});

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
          child: ClipOval(
            child: asyncUser.when(
              data: (user) {
                return kIsWeb
                    ? Image.network(
                        user.profilePicture,
                        fit: BoxFit.fill,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return const LoadingProfileImage();
                        },
                      )
                    : CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl: user.profilePicture,
                        placeholder: (context, url) =>
                            const LoadingProfileImage(),
                        errorWidget: (context, url, error) =>
                            const LoadingProfileImage(),
                      );
              },
              error: (_, __) {
                return const Text('Error');
              },
              loading: () => LoadingProfileImage(),
            ),
          ),
        ),
      ),
    );
  }
}
