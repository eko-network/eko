import 'package:eko_app/utilities/platform.dart' as platform;
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Version {
  bool lessThanMin = false;
  String currentVersion = '';
  String minimumVersion = '';
  Future<void> init() async {
    await Future.wait([getCurrentAppVersion(), getAppVersion()]);
    lessThanMin = compareVersions(currentVersion, minimumVersion) == -1;
  }

  // Function to retrieve the current app version
  Future<void> getCurrentAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo.version;
  }

  Future<void> getAppVersion() async {
    if (platform.isMobile) {
      minimumVersion = await supabase.rpc(
        'get_min_version',
        params: {'p_platform': platform.isIOS ? 'ios' : 'android'},
      );
    } else {
      minimumVersion = '0.0.0';
      return;
    }
  }

  int compareVersions(String a, String b) {
    List<int> aParts = a.split('.').map(int.parse).toList();
    List<int> bParts = b.split('.').map(int.parse).toList();

    for (int i = 0; i < aParts.length; i++) {
      if (i >= bParts.length) {
        return 1; // a is greater
      }

      if (aParts[i] > bParts[i]) {
        return 1;
      } else if (aParts[i] < bParts[i]) {
        return -1;
      }
    }

    if (aParts.length < bParts.length) {
      return -1; // b is greater
    }

    return 0; // Versions are equal
  }
}
