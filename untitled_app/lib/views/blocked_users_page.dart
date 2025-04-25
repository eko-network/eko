import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as prov;
import 'package:untitled_app/controllers/blocked_users_page_controller.dart';
import 'package:untitled_app/custom_widgets/pagination.dart';
import 'package:untitled_app/custom_widgets/searched_user_card.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';

class BlockedUsersPage extends StatelessWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).width;
    return prov.ChangeNotifierProvider(
      create: (context) => BlockedUsersPageController(),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => context.pop(),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              AppLocalizations.of(context)!.blockedAccounts,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.all(height * 0.02),
            child: PaginationPage(
                externalData: prov.Provider.of<BlockedUsersPageController>(context,
                        listen: true)
                    .users,
                getter: prov.Provider.of<BlockedUsersPageController>(context,
                        listen: false)
                    .userGetter,
                card: blockedPageBuilder,
                startAfterQuery: prov.Provider.of<BlockedUsersPageController>(
                        context,
                        listen: false)
                    .startAfterQuery,
                extraRefresh: prov.Provider.of<BlockedUsersPageController>(
                        context,
                        listen: false)
                    .onRefresh),
          ),
        );
      },
    );
  }
}
