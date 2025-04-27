import 'package:shared_preferences/shared_preferences.dart';

Future<bool> getActivityNotification() async {
  const activityNotification = 'ACTIVITY_NOTIFICATION';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool? value = prefs.getBool(activityNotification);
  if (value == null) {
    prefs.setBool(activityNotification, true);
    return true;
  }
  return value;
}

void setActivityNotification(bool value) async {
  const activityNotification = 'ACTIVITY_NOTIFICATION';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(activityNotification, value);
}

Future<bool?> getBool(String name)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(name);
}
void setBool(String name, bool bool)async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(name, bool);
}
