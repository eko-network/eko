import 'package:flutter/foundation.dart';
import '../utilities/constants.dart' as c;
import 'package:universal_html/html.dart' as html;

class DownloadPageController extends ChangeNotifier {
  DownloadPageController() {
    if (kIsWeb) {
      redirectToStore();
    }
  }
//these change current tab
  void redirectToStore() {
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
    // else {
    //   // Redirect to website for other devices
    //   // html.window.location.href = "https://www.google.com";
    //   //launchPlayStore();
    // }
  }
//these open in new tab
 
}
