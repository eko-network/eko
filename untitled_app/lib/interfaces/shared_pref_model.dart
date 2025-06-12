import 'package:untitled_app/utilities/shared_pref_service.dart';

bool getActivityNotification() {
  const activityNotification = 'ACTIVITY_NOTIFICATION';
  final prefs = PrefsService.instance;
  final bool? value = prefs.getBool(activityNotification);
  if (value == null) {
    prefs.setBool(activityNotification, true);
    return true;
  }
  return value;
}

void setActivityNotification(bool value) {
  const activityNotification = 'ACTIVITY_NOTIFICATION';
  final prefs = PrefsService.instance;
  prefs.setBool(activityNotification, value);
}

bool? getBool(String name) {
  final prefs = PrefsService.instance;
  return prefs.getBool(name);
}

void setBool(String name, bool bool) {
  final prefs = PrefsService.instance;
  prefs.setBool(name, bool);
}
