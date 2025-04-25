import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as prov;
import 'package:untitled_app/controllers/blocked_users_page_controller.dart';
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/models/users.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/utilities/locator.dart';

class SearchedUserController extends ChangeNotifier {
  final AppUser user;
  final BuildContext context;
  AppUser? loadedUser;
  late bool following;
  bool isFollowing = false;
  final bool groupSearch;
  final bool? initialBool;
  late bool added;
  final bool blockPage;
  TextEditingController commentFeild = TextEditingController();
  final void Function(AppUser, bool)? adder;
  SearchedUserController(
      {required this.context,
      required this.user,
      required this.blockPage,
      this.loadedUser,
      required this.groupSearch,
      this.adder,
      this.initialBool}) {
    _init();
  }

  @override
  void dispose() {
    commentFeild.dispose();
    super.dispose();
  }

  void _init() {
    loadedUser = user;
    if (groupSearch) {
      added = initialBool!;
    } else {
      following = locator<CurrentUser>().checkIsFollowing(loadedUser!.uid);
    }

    notifyListeners();
  }

  bool isBlockedByMe() {
    return locator<CurrentUser>().blockedUsers.contains(user.uid);
  }

  bool blocksMe() {
    return locator<CurrentUser>().blockedBy.contains(user.uid);
  }

  void onCardPressed() {
    if (!blockPage) context.push('/feed/sub_profile/${user.uid}', extra: user);
  }

  void unblockPressed() {
    prov.Provider.of<BlockedUsersPageController>(context, listen: false)
        .unblockUser(user.uid);
  }
  // onFollowPressed() async {
  //   if (following) {
  //     if (await locator<CurrentUser>().removeFollower(loadedUser!.uid)) {
  //       following = false;
  //       loadedUser!.followers.remove(locator<CurrentUser>().uid);
  //     }
  //   } else {
  //     if (await locator<CurrentUser>().addFollower(loadedUser!.uid)) {
  //       following = true;
  //       loadedUser!.followers.add(locator<CurrentUser>().uid);
  //     }
  //   }
  //   notifyListeners();
  // }

  onFollowPressed() async {
    if (loadedUser!.uid != locator<CurrentUser>().uid) {
      if (!isFollowing) {
        isFollowing = true;
        following = locator<CurrentUser>().checkIsFollowing(loadedUser!.uid);
        if (following) {
          following = false;
          loadedUser!.followers
              .remove(locator<CurrentUser>().getUID()); //subtract;
          notifyListeners();
          if (!(await locator<CurrentUser>().removeFollower(loadedUser!.uid))) {
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

  void onAddPressed() {
    if (added) {
      adder!(user, false);
      //added = false;
    } else {
      adder!(user, true);
      //added = true;
    }
    notifyListeners();
  }
}
