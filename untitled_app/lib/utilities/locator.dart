import 'package:get_it/get_it.dart';
import '../models/current_user.dart';

final locator = GetIt.instance;
void setupLocator() {
  locator.registerLazySingleton<CurrentUser>(() => CurrentUser());
}
