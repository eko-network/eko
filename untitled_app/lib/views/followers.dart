import 'package:flutter/material.dart';
import 'package:untitled_app/controllers/followers_controller.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../custom_widgets/searched_user_card.dart';
import '../custom_widgets/pagination.dart';
import 'package:untitled_app/models/users.dart';

class Followers extends StatelessWidget {
  final AppUser user;

  const Followers({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return ChangeNotifierProvider(
        create: (context) =>
            FollowersController(context: context, rootUser: user),
        builder: (context, child) {
          return Scaffold(
              appBar: AppBar(
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 20,
                  ),
                  onPressed: () => context.pop("poped"),
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
                padding: EdgeInsets.symmetric(
                    vertical: height * 0.01, horizontal: 6),
                child: PaginationPage(
                    getter:
                        Provider.of<FollowersController>(context, listen: false)
                            .userGetter,
                    card: searchPageBuilder,
                    startAfterQuery:
                        Provider.of<FollowersController>(context, listen: false)
                            .startAfterQuery,
                    extraRefresh:
                        Provider.of<FollowersController>(context, listen: false)
                            .onRefresh),
              ));
        });
  }
}
