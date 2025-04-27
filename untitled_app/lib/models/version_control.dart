import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Version {
  bool lessThanMin = false;
  bool lessThanTarget = false;
  String currentVersion = '';
  String targetVersion = '';
  String minimumVersion = '';
  Future<void> init() async {
    await getCurrentAppVersion();
    await getAppVersion();
    lessThanMin = compareVersions(currentVersion, minimumVersion) == -1;
    lessThanTarget = compareVersions(currentVersion, targetVersion) == -1;
  }

// Function to retrieve the current app version
  Future<void> getCurrentAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo.version;
  }

// Replace this function with the actual function to retrieve the version from Firebase
  Future<void> getAppVersion() async {
    bool ios = Platform.isIOS;
    bool android = Platform.isAndroid;
    final collectrionRef = FirebaseFirestore.instance.collection('utilities');
    late DocumentSnapshot<Map<String, dynamic>> snapshot;

    if (ios) {
      snapshot = await collectrionRef.doc('iosVersion').get();
    } else if (android) {
      snapshot = await collectrionRef.doc('androidVersion').get();
    } else {
      minimumVersion = '0.0.0';
      targetVersion = '0.0.0';
      return;
    }
    final data = snapshot.data();
    if (data != null) {
      minimumVersion = data['minimum'];
      targetVersion = data['target'];
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
