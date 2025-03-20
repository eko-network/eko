import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/controllers/bottom_nav_bar_controller.dart';
import 'package:untitled_app/custom_widgets/warning_dialog.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/models/users.dart';
import '../models/current_user.dart';
import '../utilities/locator.dart';
import '../models/post_handler.dart';
import '../custom_widgets/controllers/pagination_controller.dart'
    show PaginationGetterReturn;
import '../models/feed_post_cache.dart' show Cache;

class OtherProfileController extends ChangeNotifier {
  final BuildContext context;
  final AppUser? passedUser;
  final String id;
  Cache loadedPostData = Cache(items: [], end: false);

  AppUser? loadedUser;
  late bool following;
  bool isFollowing = false;
  OtherProfileController({
    required this.context,
    required this.passedUser,
    this.loadedUser,
    required this.id,
  }) {
    _init();
  }
  void _init() async {
    if (passedUser != null) {
      loadedUser = passedUser!;
    } else {
      AppUser user = AppUser();
      await user.readUserData(id);
      loadedUser = user;
    }
    if (loadedUser!.uid == locator<CurrentUser>().getUID()) {
      context.go("/profile");
    }
    following = locator<CurrentUser>().checkIsFollowing(loadedUser!.uid);
    //set blocked

    if (!isLoggedIn()) {
      locator<NavBarController>().disable();
    }
    notifyListeners();
  }

  bool isLoggedIn() {
    if (locator<CurrentUser>().getUID() == '') {
      return false;
    }
    return true;
  }

  bool isBlockedByMe() {
    return locator<CurrentUser>().blockedUsers.contains(loadedUser!.uid);
  }

  bool blocksMe() {
    return locator<CurrentUser>().blockedBy.contains(loadedUser!.uid);
  }

  void showLogInDialog() {
    showMyDialog(
        AppLocalizations.of(context)!.logIntoApp,
        AppLocalizations.of(context)!.logInRequired,
        [
          AppLocalizations.of(context)!.goBack,
          AppLocalizations.of(context)!.signIn
        ],
        [_popDialog, _goToLogin],
        context,
        dismissable: true);
  }

  void _popDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _goToLogin() {
    context.go('/');
  }


  void showBlock() {
    showMyDialog(
        AppLocalizations.of(context)!.blockTitle,
        AppLocalizations.of(context)!.blockBody,
        [
          AppLocalizations.of(context)!.cancel,
          AppLocalizations.of(context)!.block
        ],
        [_popDialog, _blockPressed],
        context,
        dismissable: true);
  }

  // void showUnblock() {
  //   showMyDialog(
  //       AppLocalizations.of(context)!.unblockTitle,
  //       AppLocalizations.of(context)!.unblockbody,
  //       [
  //         AppLocalizations.of(context)!.cancel,
  //         AppLocalizations.of(context)!.unblock
  //       ],
  //       [_popDialog, _unblockPressed],
  //       context,
  //       dismissable: true);
  // }

  void _blockPressed() async {
    _popDialog();
    await locator<CurrentUser>().blockUser(loadedUser!.uid);
    context.go('/feed', extra: true);
  }

  // void _unblockPressed() {
  //   _popDialog();
  //   locator<CurrentUser>().unblockUser(loadedUser!.uid);
  // }

  onFollowPressed() async {
    if (!isLoggedIn()) {
      showLogInDialog();
    } else {
      if ((loadedUser!.username != "") &&
          (loadedUser!.uid != locator<CurrentUser>().uid)) {
        if (!isFollowing) {
          isFollowing = true;
          following = locator<CurrentUser>().checkIsFollowing(loadedUser!.uid);
          if (following) {
            following = false;
            loadedUser!.followers
                .remove(locator<CurrentUser>().getUID()); //subtract;
            notifyListeners();
            if (!(await locator<CurrentUser>()
                .removeFollower(loadedUser!.uid))) {
              following = true;
              loadedUser!.followers
                  .add(locator<CurrentUser>().getUID()); //subtract;
              notifyListeners();
            }
          } else {
            following = true;
            loadedUser!.followers
                .add(locator<CurrentUser>().getUID()); //subtract;
            notifyListeners();
            if (!(await locator<CurrentUser>().addFollower(loadedUser!.uid))) {
              following = false;
              loadedUser!.followers
                  .remove(locator<CurrentUser>().getUID()); //subtract;
              notifyListeners();
            }
          }

          isFollowing = false;
        }
      }
    }
  }

  dynamic getTimeFromPost(dynamic post) {
    return locator<PostsHandling>().getTimeFromPost(post);
  }

  Future<PaginationGetterReturn> getPosts(dynamic time) {
    return locator<PostsHandling>().getSubProfilePosts(time, loadedUser!);
  }

  onPageRefresh() {
    if (loadedUser != null) {
      loadedUser!.readUserData(null);
      notifyListeners();
    }
  }
}
