import 'package:flutter/material.dart';
import 'profile_picture_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.url,
    this.size,
    this.online = false,
  });

  final double? size;
  final String url;
  final bool online;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          ClipOval(
            child: kIsWeb
                ? Image.network(
                    url,
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
                    imageUrl: url,
                    placeholder: (context, url) => const LoadingProfileImage(),
                    errorWidget: (context, url, error) =>
                        const LoadingProfileImage(),
                  ),
          ),
          if (online)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: (size ?? 40) * 0.25,
                height: (size ?? 40) * 0.25,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
