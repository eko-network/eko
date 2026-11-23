import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:eko_app/utilities/default_profile_asset.dart';
import 'package:eko_app/widgets/loading/profile_picture_loading.dart';

class NetworkOrDefaultProfileImage extends StatelessWidget {
  const NetworkOrDefaultProfileImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Image.asset(kDefaultProfilePictureAsset, fit: fit);
    }
    return CachedNetworkImage(
      fit: fit,
      imageUrl: imageUrl,
      placeholder: (context, url) => const LoadingProfileImage(),
      errorWidget: (context, url, error) =>
          Image.asset(kDefaultProfilePictureAsset, fit: fit),
    );
  }
}
