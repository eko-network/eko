import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';

class GifWidget extends StatelessWidget {
  final String url;
  const GifWidget({super.key, required this.url});

  bool get isKlipyGif => url.contains('static.klipy.com');

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Image.network(
            url,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) =>
                Text(AppLocalizations.of(context)!.gifLoadingError),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return Container(
                alignment: Alignment.center,
                width: 200,
                height: 150,
                color: Theme.of(context).colorScheme.onSurface,
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
          if (isKlipyGif)
            Positioned(
              bottom: 5,
              left: 5,
              child: Opacity(
                opacity: 0.7,
                child: SvgPicture.asset(
                  'images/klipy-light.svg',
                  width: 7,
                  height: 7,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
