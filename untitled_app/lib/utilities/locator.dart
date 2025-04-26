import 'package:get_it/get_it.dart';
import 'package:untitled_app/models/presence_manager.dart';
import '../models/notification_service.dart';
import '../models/current_user.dart';
import '../models/post_handler.dart';
import '../controllers/bottom_nav_bar_controller.dart';
import '../models/feed_post_cache.dart';
import '../models/version_control.dart';

final locator = GetIt.instance;
void setupLocator() {
  locator.registerLazySingleton<CurrentUser>(() => CurrentUser());
  locator.registerSingleton<PresenceManager>(PresenceManager());
  locator.registerLazySingleton<PostsHandling>(() => PostsHandling());
  locator.registerSingleton<NavBarController>(NavBarController());
  locator.registerLazySingleton<FeedPostCache>(() => FeedPostCache());
  locator.registerSingleton<NotificationService>(NotificationService());
  locator.registerSingleton<Version>(Version());
}
