import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:qr_flutter_new/qr_flutter.dart';
import '../utilities/constants.dart' as c;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../models/uri_launcher.dart';

class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key});

  void redirectToStore() {
    if (kIsWeb) {
      var userAgent = html.window.navigator.userAgent;
      if (userAgent.contains(RegExp(r'android', caseSensitive: false))) {
        // Redirect to Google Play Store
        html.window.location.href = c.playStoreURL;
      } else if (userAgent
              .contains(RegExp(r'iPad|iPhone|iPod', caseSensitive: false)) &&
          !userAgent.contains('MSStream')) {
        // Redirect to Apple App Store
        html.window.location.href = c.appStoreURL;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
          title: Text(AppLocalizations.of(context)!.download),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.8,
                child: QrImageView(
                  //gapless: true,
                  data: '${c.appURL}/download',
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  dataModuleStyle: QrDataModuleStyle(
                      borderRadius: 4,
                      color: Theme.of(context).colorScheme.onSurface),
                  eyeStyle: QrEyeStyle(
                      borderRadius: 4,
                      color: Theme.of(context).colorScheme.onSurface,
                      eyeShape: QrEyeShape.square),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              InkWell(
                onTap: () => UriLauncher.launchPlayStore(),
                child: SvgPicture.asset(
                  'images/playStoreButton.svg',
                  width: width * 0.45,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              InkWell(
                onTap: () => UriLauncher.launchAppStore(),
                child: SvgPicture.asset(
                  'images/appStoreButton.svg',
                  width: width * 0.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
