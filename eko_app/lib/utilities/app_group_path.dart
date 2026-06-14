import 'dart:io' show Platform;
import 'package:flutter/services.dart';

const _channel = MethodChannel('PushNotificationChannel');

Future<String?> getAppGroupPath() async {
  if (!Platform.isIOS) return null;
  try {
    return await _channel.invokeMethod<String>('getAppGroupPath');
  } catch (e) {
    return null;
  }
}
