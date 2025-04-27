import 'package:flutter/material.dart';
import 'package:untitled_app/custom_widgets/controllers/pagination_controller.dart';
import 'package:untitled_app/models/users.dart';
import '../utilities/constants.dart' as c;

class FollowingController extends ChangeNotifier {
  final BuildContext context;
  final AppUser rootUser;

  FollowingController({
    required this.context,
    required this.rootUser,
  });

  Future<PaginationGetterReturn> userGetter(dynamic passedIndex) async {
    Future<AppUser> getUser(int i) async {
      AppUser user = AppUser(pageIndex: i);
      await user.readUserData(rootUser.following[i]);
      return user;
    }

    List<Future<AppUser>> returnList = [];
    int startIndex = (passedIndex ?? -1) + 1;
    final bool end = (rootUser.following.length < startIndex + c.usersOnSearch);

    for (int i = startIndex;
        i <
            (end
                ? (rootUser.following.length)
                : (startIndex + c.usersOnSearch));
        i++) {
      returnList.add(getUser(i));
    }
    return PaginationGetterReturn(payload: await Future.wait(returnList), end: end);
  }

  dynamic startAfterQuery(dynamic user) {
    user as AppUser;
    return user.pageIndex;
  }

  void onRefresh() async {
    await rootUser.readUserData(rootUser.uid);
  }

//   Future <void> initUser() async {
//   if (_isInitUserRunning) {
//     return;
//   }
//   _isInitUserRunning = true;
//   followingList.clear();
//   for (var uid in following) {
//     AppUser user = AppUser();
//     Map<String, dynamic>? userData = await user.readUserData(uid);
//     if (userData != null) {
//       followingList.add(AppUser.fromJson(userData));
//     }
//   }
//   _isInitUserRunning = false;
//   notifyListeners();
// }
}
