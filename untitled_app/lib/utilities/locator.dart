import 'package:get_it/get_it.dart';
import 'package:untitled_app/models/presence_manager.dart';
import '../models/current_user.dart';
import '../models/post_handler.dart';
import '../controllers/bottom_nav_bar_controller.dart';
import '../models/version_control.dart';

final locator = GetIt.instance;
void setupLocator() {
  locator.registerLazySingleton<CurrentUser>(() => CurrentUser());
  locator.registerSingleton<PresenceManager>(PresenceManager());
  locator.registerLazySingleton<PostsHandling>(() => PostsHandling());
  locator.registerSingleton<NavBarController>(NavBarController());
  locator.registerSingleton<Version>(Version());
}
