import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/utilities/constants.dart' as c;
import 'package:untitled_app/widgets/user_card.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';

class BlockedUsersPage extends ConsumerWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
    final currentUser = ref.watch(currentUserProvider);
    //FIXME
    final blockedList = []; //List<String>.from(currentUser.blockedUsers);
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
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(currentUserProvider.notifier).reload();
        },
        child: ListView.builder(
          itemCount: blockedList.length,
          itemBuilder: (context, index) => UserCard(
            showBlockedUsers: true,
            uid: blockedList[index],
            onCardPressed: (_) {},
            actionWidget: (user) => InkWell(
              onTap: () =>
                  ref.read(currentUserProvider.notifier).unBlockUser(user.uid),
              child: Container(
                width: width * 0.25,
                height: width * 0.1,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                child: Text(
                  AppLocalizations.of(context)!.unblock,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
