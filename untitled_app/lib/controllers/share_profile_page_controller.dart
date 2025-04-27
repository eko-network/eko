import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/utilities/locator.dart';
import 'package:untitled_app/views/share_profile_page.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import '../utilities/constants.dart' as c;

class ShareProfilePageController extends ChangeNotifier {
  bool linkCopied = false;
  bool sharing = false;
  void copyLinkPressed() {
    linkCopied = true;
    Clipboard.setData(ClipboardData(
        text:
            '${c.appURL}/feed/sub_profile/${locator<CurrentUser>().getUID()}'));
    notifyListeners();
  }

  void sharePressed() async {
    if (!sharing) {
      sharing = true;
      RenderRepaintBoundary boundary = repaintKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      File imgFile = File('${appDocumentsDir.path}/qr.png');
      await imgFile.writeAsBytes(pngBytes);

      Share.shareXFiles(
        [XFile(imgFile.path)],
        text: '${c.appURL}/feed/sub_profile/${locator<CurrentUser>().getUID()}',
      );
      sharing = false;
    }
  }
}
