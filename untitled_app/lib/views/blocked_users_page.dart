import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/widgets/user_card.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';

class BlockedUsersPage extends ConsumerWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final blockedList = List<String>.from(currentUser.blockedUsers);
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
            blockedPage: true,
            uid: blockedList[index],
          ),
        ),
      ),
    );
  }
}
