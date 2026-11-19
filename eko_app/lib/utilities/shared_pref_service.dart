import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static SharedPreferencesWithCache? _prefs;

  static const String _keyTheme = 'THEMESTATUS';
  static const String _keyNotifications = 'ACTIVITY_NOTIFICATION';
  static const String _keyPostPreview = 'SHOW_POST_PREVIEW';
  static const String _keyHasShownPreviewInfo = 'HAS_SHOWN_PREVIEW_INFO';
  static const String _keyNotFirstInstall = 'NOT_FIRST_INSTALL';
  static const String _keyLastFeedPageIndex = 'LAST_FEED_PAGE_INDEX';
  static const String _keyWebUdidPresence = 'web_udid_presence';
  static const String _keyDeviceUid = 'DEVICE_UID';
  static const String _keyDeviceToken = 'DEVICE_PUSH_TOKEN';
  static const String _keyDeviceTokenLastCheckedAt =
      'DEVICE_PUSH_TOKEN_LAST_CHECKED_AT';
  static const String _keyUploadedDeviceToken = 'DEVICE_PUSH_TOKEN_UPLOADED';

  static Future<void> init() async {
    _prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
  }

  static SharedPreferencesWithCache get instance {
    if (_prefs == null) {
      throw Exception('PrefsService not initialized');
    }
    return _prefs!;
  }

  static bool get isDarkMode => instance.getBool(_keyTheme) ?? true;
  static set isDarkMode(bool value) => instance.setBool(_keyTheme, value);

  static bool get notificationsEnabled =>
      instance.getBool(_keyNotifications) ?? true;
  static set notificationsEnabled(bool value) =>
      instance.setBool(_keyNotifications, value);

  static bool get showPostPreview => instance.getBool(_keyPostPreview) ?? true;
  static set showPostPreview(bool value) =>
      instance.setBool(_keyPostPreview, value);

  static bool get hasShownPreviewInfo =>
      instance.getBool(_keyHasShownPreviewInfo) ?? false;
  static set hasShownPreviewInfo(bool value) =>
      instance.setBool(_keyHasShownPreviewInfo, value);

  static bool get notFirstInstall =>
      instance.getBool(_keyNotFirstInstall) ?? false;
  static set notFirstInstall(bool value) =>
      instance.setBool(_keyNotFirstInstall, value);
  static Future<void> markNotFirstInstall() async {
    await instance.setBool(_keyNotFirstInstall, true);
  }

  static int get lastFeedPageIndex =>
      instance.getInt(_keyLastFeedPageIndex) ?? 1;
  static set lastFeedPageIndex(int value) =>
      instance.setInt(_keyLastFeedPageIndex, value);

  static String? get webUdidPresence => instance.getString(_keyWebUdidPresence);
  static set webUdidPresence(String? value) {
    if (value == null) {
      instance.remove(_keyWebUdidPresence);
    } else {
      instance.setString(_keyWebUdidPresence, value);
    }
  }

  static String? get deviceUid => instance.getString(_keyDeviceUid);
  static set deviceUid(String? value) {
    if (value == null) {
      instance.remove(_keyDeviceUid);
    } else {
      instance.setString(_keyDeviceUid, value);
    }
  }

  static String? get deviceNotificationToken =>
      instance.getString(_keyDeviceToken);
  static set deviceNotificationToken(String? value) {
    if (value == null) {
      instance.remove(_keyDeviceToken);
    } else {
      instance.setString(_keyDeviceToken, value);
    }
  }

  /// The push endpoint the backend has for this device, null while it has
  /// none, e.g. with notifications turned off.
  static String? get uploadedNotificationToken =>
      instance.getString(_keyUploadedDeviceToken);
  static set uploadedNotificationToken(String? value) {
    if (value == null) {
      instance.remove(_keyUploadedDeviceToken);
    } else {
      instance.setString(_keyUploadedDeviceToken, value);
    }
  }

  static int? get deviceNotificationTokenLastCheckedAt =>
      instance.getInt(_keyDeviceTokenLastCheckedAt);
  static set deviceNotificationTokenLastCheckedAt(int? value) {
    if (value == null) {
      instance.remove(_keyDeviceTokenLastCheckedAt);
    } else {
      instance.setInt(_keyDeviceTokenLastCheckedAt, value);
    }
  }
}
