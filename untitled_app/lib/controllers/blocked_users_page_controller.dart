import 'package:flutter/material.dart';
import 'package:untitled_app/custom_widgets/controllers/pagination_controller.dart';
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/models/users.dart';
import 'package:untitled_app/utilities/locator.dart';
import '../utilities/constants.dart' as c;

class BlockedUsersPageController extends ChangeNotifier {
  Cache users = Cache(items: [], end: false);
  Future<PaginationGetterReturn> userGetter(dynamic passedIndex) async {
    Future<AppUser> getUser(int i) async {
      AppUser user = AppUser(pageIndex: i);
      await user.readUserData(locator<CurrentUser>().blockedUsers[i]);
      return user;
    }

    List<Future<AppUser>> returnList = [];
    int startIndex = (passedIndex ?? -1) + 1;
    final bool end = (locator<CurrentUser>().blockedUsers.length <
        startIndex + c.usersOnSearch);

    for (int i = startIndex;
        i <
            (end
                ? (locator<CurrentUser>().blockedUsers.length)
                : (startIndex + c.usersOnSearch));
        i++) {
      returnList.add(getUser(i));
    }
    return PaginationGetterReturn(
        payload: await Future.wait(returnList), end: end);
  }

  dynamic startAfterQuery(dynamic user) {
    user as AppUser;
    return user.pageIndex;
  }

  void onRefresh() async {
    await locator<CurrentUser>().readCurrentUserData();
  }

  void unblockUser(String uid) async{
    await locator<CurrentUser>().unblockUser(uid);
    users.items.removeWhere(
      (element) {
        element as AppUser;
        return element.uid == uid;
      },
    );
    notifyListeners();
  }
}
