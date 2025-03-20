import 'package:flutter/material.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';

class GifWidget extends StatelessWidget {
  final String url;
  const GifWidget({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        fit: BoxFit.fill,
        errorBuilder: (context, error, stackTrace) =>
            Text(AppLocalizations.of(context)!.gifLoadingError),
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
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
    );
  }
}
