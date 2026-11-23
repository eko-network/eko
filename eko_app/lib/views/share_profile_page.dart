import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter_new/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/utilities/platform.dart' as platform;
import 'package:eko_app/widgets/scaffolds/app_scaffold.dart';
import 'package:eko_app/widgets/scaffolds/eko_app_bar.dart';

GlobalKey repaintKey = GlobalKey();

class ShareProfile extends ConsumerStatefulWidget {
  const ShareProfile({super.key});

  @override
  ConsumerState<ShareProfile> createState() => _ShareProfileState();
}

class _ShareProfileState extends ConsumerState<ShareProfile> {
  bool linkCopied = false;
  bool sharing = false;
  void copyLinkPressed(String url) {
    Clipboard.setData(ClipboardData(text: url));
    setState(() {
      linkCopied = true;
    });
  }

  void sharePressed(String url) async {
    if (sharing) return;
    sharing = true;
    RenderRepaintBoundary boundary =
        repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    File imgFile = File('${appDocumentsDir.path}/qr.png');
    await imgFile.writeAsBytes(pngBytes);

    Share.shareXFiles([XFile(imgFile.path)], text: url);
    sharing = false;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String shareUrl =
        '${c.appURL}/users/${ref.read(currentUserProvider).user.username}';
    final width = c.widthGetter(context);
    final icon = platform.isIOS
        ? CupertinoIcons.share
        : CupertinoIcons.arrowshape_turn_up_right;
    return AppScaffold(
      appBar: EkoAppBar(
        title: Text(AppLocalizations.of(context)!.shareProfile),
      ),
      body: Center(
        child: SizedBox(
          width: width * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //ProfileAvatar(url: locator<CurrentUser>().profilePicture, size: width * 0.2,),
              RepaintBoundary(
                key: repaintKey,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        '@${ref.watch(currentUserProvider).user.username}',
                        style: TextStyle(fontSize: 24),
                      ),
                      QrImageView(
                        //gapless: true,
                        data: shareUrl,
                        //backgroundColor: Theme.of(context).colorScheme.surface,
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!kIsWeb)
                    _Icon(
                      icon: icon,
                      text: AppLocalizations.of(context)!.share,
                      onTap: () => sharePressed(shareUrl),
                    ),
                  if (!kIsWeb) const Spacer(),
                  _Icon(
                    icon: Icons.link,
                    text: linkCopied
                        ? AppLocalizations.of(context)!.copied
                        : AppLocalizations.of(context)!.copyLink,
                    onTap: () => copyLinkPressed(shareUrl),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  final String text;
  final IconData icon;
  final Function onTap;
  const _Icon({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        width: width * 0.395,
        height: width * 0.2,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: Theme.of(context).colorScheme.onSurface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.surface),
            Text(
              text,
              style: TextStyle(color: Theme.of(context).colorScheme.surface),
            ),
          ],
        ),
      ),
    );
  }
}
