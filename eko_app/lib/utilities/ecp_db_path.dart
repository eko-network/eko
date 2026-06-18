import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

const _channel = MethodChannel('PushNotificationChannel');

Future<String> getDbPath() async {
  final dir = await getApplicationSupportDirectory();
  if (!Platform.isIOS) {
    return dir.path;
  }
  try {
    return await _channel.invokeMethod<String>('getAppGroupPath') ?? dir.path;
  } catch (e) {
    return dir.path;
  }
}
