import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import 'package:eko_app/utilities/shared_pref_service.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/interfaces/notification_helper.dart';
import 'package:eko_app/utilities/device_uid_service.dart';
import 'package:eko_app/utilities/notification_type_helper.dart';

Future<bool> isUsernameAvailable(String username) async {
  try {
    return await supabase.rpc(
      'is_username_available',
      params: {'p_username': username},
    );
  } catch (e) {
    debugPrint(e.toString());
    return true;
  }
}

bool isUsernameValid(String username) {
  return username.trim().contains(RegExp(c.userNameReqs));
}

Future<void> addDeviceNotificationToken(String uid) async {
  if (!kIsWeb) {
    try {
      final token = await NotificationHelper.waitForDeviceToken(
        forBackendSync: true,
      );
      print("TOKEN: $token");
      if (token == null) {
        PrefsService.notificationsEnabled = false;
        PrefsService.deviceNotificationToken = null;
        return;
      }
      PrefsService.deviceNotificationToken = token;
      await _updateNotifications(token: token, isActive: true);
      PrefsService.notificationsEnabled = true;
    } catch (e) {
      debugPrint('addDeviceNotificationToken error: $e');
    }
  }
}

Future<void> removeDeviceNotificationToken(String uid) async {
  if (!kIsWeb) {
    try {
      final token = await NotificationHelper.getDeviceToken();
      if (token == null) return;
      await _updateNotifications(token: token, isActive: false);
      PrefsService.notificationsEnabled = false;
      PrefsService.deviceNotificationToken = null;
      PrefsService.deviceNotificationTokenLastCheckedAt = null;
    } catch (e) {
      debugPrint('removeDeviceNotificationToken error: $e');
    }
  }
}

Future<void> refreshDeviceNotificationTokenIfNeeded(String uid) async {
  if (!kIsWeb) {
    try {
      final previousToken = PrefsService.deviceNotificationToken;
      final updated = await NotificationHelper.refreshDeviceTokenIfNeeded();
      // catch if the user denies OS "notification enabled" prompt
      if (!PrefsService.notificationsEnabled && previousToken != null) {
        await _updateNotifications(token: previousToken, isActive: false);
        return;
      }
      if (!updated) return;
      final token = PrefsService.deviceNotificationToken;
      if (token == null) return;
      await _updateNotifications(token: token, isActive: true);
    } catch (e) {
      debugPrint('refreshDeviceNotificationTokenIfNeeded error: $e');
    }
  }
}

Future<void> _updateNotifications({
  required String token,
  required bool isActive,
}) async {
  final deviceUid = DeviceUidService.getOrCreate();
  await supabase.rpc(
    'update_notifications',
    params: {
      'p_device_id': deviceUid,
      'p_token': token,
      'p_active': isActive,
      'p_device_type': deviceTypeFromPlatform(),
      'p_notification_type': notificationTypeFromPlatform(),
    },
  );
}

Future<String> forgotPassword({
  required String? countryCode,
  required String email,
}) async {
  try {
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: c.forgotPasswordURL,
    );
    return 'success';
  } catch (e) {
    return 'unknown';
  }
}

Future<String?> getUidFromUsername(String username) async {
  final data = await supabase
      .from('users')
      .select('id')
      .eq('username', username)
      .maybeSingle();
  return data?['id'] as String?;
}

Future<String> verifyPasswordReset(String code) async {
  try {
    final response = await supabase.auth.verifyOTP(
      type: supabase_flutter.OtpType.recovery,
      token: code,
    );
    return response.user?.email ?? '';
  } catch (e) {
    debugPrint('verifyPasswordReset error: $e');
    rethrow;
  }
}

Future<String> resetPassword(String code, String password) async {
  try {
    await supabase.auth.updateUser(
      supabase_flutter.UserAttributes(password: password),
    );
    return 'success';
  } catch (e) {
    debugPrint('resetPassword error: $e');
    return 'unknown';
  }
}
