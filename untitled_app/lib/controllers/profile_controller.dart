import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/models/users.dart' show AppUser;
import '../models/post_handler.dart';
import '../models/current_user.dart';
import 'bottom_nav_bar_controller.dart';
import '../utilities/locator.dart';
import '../custom_widgets/controllers/pagination_controller.dart'
    show PaginationGetterReturn;

class ProfileController extends ChangeNotifier {
  final BuildContext context;
  late AppUser user;

  ProfileController({
    required this.context,
  }) {
    initUser();
  }
  onPageRefresh() {
    loadUserData();
  }

//FIXME maybe move to a standard class format for more reusablity
  initUser() {
    user = AppUser(
      uid: locator<CurrentUser>().uid,
      name: locator<CurrentUser>().name,
      username: locator<CurrentUser>().username,
      profilePicture: locator<CurrentUser>().profilePicture,
      bio: locator<CurrentUser>().bio,
      likes: locator<CurrentUser>().likes,
      dislikes: locator<CurrentUser>().dislikes,
      followers: locator<CurrentUser>().followers,
      following: locator<CurrentUser>().following,
      isVerified: locator<CurrentUser>().isVerified,
    );

    notifyListeners();
  }

  Future<bool> onWillPop() async {
    locator<NavBarController>().goBranch(0);
    return false;
  }

//FIXME doesn't updat
  editProfilePressed() async {
    locator<NavBarController>().disable();
    await context.push("/profile/edit_profile");

    locator<NavBarController>().enable();
    user.profilePicture = locator<CurrentUser>().profilePicture;
    user.bio = locator<CurrentUser>().bio;
    user.name = locator<CurrentUser>().name;
    user.username = locator<CurrentUser>().username;
    notifyListeners();
  }

  settingsButtonPressed() async {
    locator<NavBarController>().disable();
    await context.push('/profile/user_settings');
    locator<NavBarController>().enable();
  }

  qrButtonPressed() async {
    locator<NavBarController>().disable();
    await context.push('/profile/share_profile');
    locator<NavBarController>().enable();
  }

  String getUID() {
    return locator<CurrentUser>().getUID();
  }

  Future<PaginationGetterReturn> getProfilePosts(dynamic time) {
    return locator<PostsHandling>().getProfilePosts(time);
  }

  dynamic getTimeFromPost(dynamic post) {
    return locator<PostsHandling>().getTimeFromPost(post);
  }

  void loadUserData() async {
    await locator<CurrentUser>().readCurrentUserData();
    initUser();
    notifyListeners();
  }
}
