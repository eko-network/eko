import 'package:flutter/material.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../custom_widgets/searched_user_card.dart';
import '../custom_widgets/pagination.dart';
import 'package:untitled_app/models/users.dart';
import 'package:untitled_app/custom_widgets/controllers/pagination_controller.dart';
import '../utilities/constants.dart' as c;

class Followers extends StatefulWidget {
  final AppUser user;
  const Followers({required this.user, super.key});
  @override
  State<Followers> createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  Future<PaginationGetterReturn> userGetter(dynamic passedIndex) async {
    Future<AppUser> getUser(int i) async {
      AppUser user = AppUser(pageIndex: i);
      await user.readUserData(widget.user.followers[i]);
      return user;
    }

    List<Future<AppUser>> returnList = [];
    int startIndex = (passedIndex ?? -1) + 1;
    final bool end =
        (widget.user.followers.length < startIndex + c.usersOnSearch);

    for (int i = startIndex;
        i <
            (end
                ? (widget.user.followers.length)
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
    await widget.user.readUserData(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => context.pop('poped'),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          AppLocalizations.of(context)!.followers,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: height * 0.01, horizontal: 6),
        child: PaginationPage(
          getter: userGetter,
          card: searchPageBuilder,
          startAfterQuery: startAfterQuery,
          extraRefresh: onRefresh,
        ),
      ),
    );
  }
}
