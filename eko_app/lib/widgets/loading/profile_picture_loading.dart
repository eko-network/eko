import 'package:material_ui/material_ui.dart';
import 'package:shimmer/shimmer.dart';
import 'package:eko_app/utilities/default_profile_asset.dart';

class LoadingProfileImage extends StatelessWidget {
  const LoadingProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(kDefaultProfilePictureAsset),
        Shimmer.fromColors(
          baseColor: const Color.fromARGB(100, 130, 131, 130),
          highlightColor: Colors.white,
          child: Opacity(
            opacity: 0.8,
            child: Image.asset(kDefaultProfilePictureAsset),
          ),
        ),
      ],
    );
  }
}
