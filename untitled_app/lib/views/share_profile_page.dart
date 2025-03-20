import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter_new/qr_flutter.dart';
import 'package:untitled_app/controllers/share_profile_page_controller.dart';

import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/utilities/locator.dart';
import '../utilities/constants.dart' as c;

GlobalKey repaintKey = GlobalKey();

class ShareProfile extends StatelessWidget {
  const ShareProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final url =
        "${c.appURL}/feed/sub_profile/${locator<CurrentUser>().getUID()}";
    final icon = kIsWeb
        ? CupertinoIcons.arrowshape_turn_up_right
        : Platform.isIOS
            ? CupertinoIcons.share
            : CupertinoIcons.arrowshape_turn_up_right;
    return ChangeNotifierProvider(
      create: (context) => ShareProfilePageController(),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => context.pop("poped"),
            ),
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text(AppLocalizations.of(context)!.shareProfile),
            backgroundColor: Theme.of(context).colorScheme.surface,
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
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          color: Theme.of(context).colorScheme.surface),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            "@${locator<CurrentUser>().username}",
                            style: TextStyle(fontSize: 24),
                          ),
                          QrImageView(
                            //gapless: true,
                            data: url,
                            //backgroundColor: Theme.of(context).colorScheme.surface,
                            dataModuleStyle: QrDataModuleStyle(
                                borderRadius: 4,
                                color: Theme.of(context).colorScheme.onSurface),
                            eyeStyle: QrEyeStyle(
                                borderRadius: 4,
                                color: Theme.of(context).colorScheme.onSurface,
                                eyeShape: QrEyeShape.square),
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
                          onTap: Provider.of<ShareProfilePageController>(
                                  context,
                                  listen: false)
                              .sharePressed,
                        ),
                      if (!kIsWeb) const Spacer(),
                      _Icon(
                        icon: Icons.link,
                        text: !Provider.of<ShareProfilePageController>(context,
                                    listen: true)
                                .linkCopied
                            ? AppLocalizations.of(context)!.copyLink
                            : AppLocalizations.of(context)!.copied,
                        onTap: Provider.of<ShareProfilePageController>(context,
                                listen: false)
                            .copyLinkPressed,
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
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
            color: Theme.of(context).colorScheme.onSurface),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.surface,
            ),
            Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
              ),
            )
          ],
        ),
      ),
    );
  }
}
