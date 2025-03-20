import 'package:flutter/material.dart';
import 'package:untitled_app/controllers/following_controller.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/models/users.dart';
import '../custom_widgets/searched_user_card.dart';
import '../custom_widgets/pagination.dart';

class Following extends StatelessWidget {
  final AppUser user;

  const Following({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return ChangeNotifierProvider(
      create: (context) =>
          FollowingController(context: context, rootUser: user),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,),
              onPressed: () => context.pop(),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              AppLocalizations.of(context)!.following,
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
                getter: Provider.of<FollowingController>(context, listen: false)
                    .userGetter,
                card: searchPageBuilder,
                startAfterQuery:
                    Provider.of<FollowingController>(context, listen: false)
                        .startAfterQuery, extraRefresh:
                      Provider.of<FollowingController>(context, listen: false)
                          .onRefresh),
          ),
          
        );
      },
    );
  }
}
