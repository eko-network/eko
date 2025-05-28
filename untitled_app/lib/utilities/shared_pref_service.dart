import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static SharedPreferencesWithCache? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions());
  }

  static SharedPreferencesWithCache get instance {
    if (_prefs == null) {
      throw Exception('PrefsService not initialized');
    }
    return _prefs!;
  }
}
