import 'package:material_ui/material_ui.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:qr_flutter_new/qr_flutter.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/interfaces/uri_launcher.dart';
import 'package:eko_app/widgets/scaffolds/app_scaffold.dart';
import 'package:eko_app/widgets/scaffolds/eko_app_bar.dart';

class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        context.go('/');
      },
      child: AppScaffold(
        appBar: EkoAppBar(title: Text(AppLocalizations.of(context)!.download)),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    eyeStyle: QrEyeStyle(
                      borderRadius: 4,
                      color: Theme.of(context).colorScheme.onSurface,
                      eyeShape: QrEyeShape.square,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                InkWell(
                  onTap: () => UriLauncher.launchPlayStore(),
                  child: SvgPicture.asset(
                    'images/playStoreButton.svg',
                    width: width * 0.45,
                  ),
                ),
                const SizedBox(height: 5),
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
      ),
    );
  }
}
