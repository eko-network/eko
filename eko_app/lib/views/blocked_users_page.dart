import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/widgets/scaffolds/app_scaffold.dart';
import 'package:eko_app/widgets/scaffolds/eko_app_bar.dart';

//FIXME was using firebase style block
class BlockedUsersPage extends ConsumerWidget {
  const BlockedUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
    return AppScaffold(
      appBar: EkoAppBar(
        title: Text(AppLocalizations.of(context)!.blockedAccounts),
      ),
      body: Placeholder(),

      // RefreshIndicator(
      //   onRefresh: () async {
      //     await ref.read(currentUserProvider.notifier).reload();
      //   },
      //   child: ListView.builder(
      //     physics: const AlwaysScrollableScrollPhysics(),
      //     itemCount: blockedList.length,
      //     itemBuilder: (context, index) => UserCard(
      //       showBlockedUsers: true,
      //       uid: blockedList[index],
      //       onCardPressed: (_) {},
      //       actionWidget: (user) => InkWell(
      //         onTap: () =>
      //             ref.read(currentUserProvider.notifier).unBlockUser(user.uid),
      //         child: Container(
      //           width: width * 0.25,
      //           height: width * 0.1,
      //           alignment: Alignment.center,
      //           decoration: BoxDecoration(
      //             borderRadius: const BorderRadius.all(Radius.circular(5)),
      //             color: Theme.of(context).colorScheme.outlineVariant,
      //           ),
      //           child: Text(
      //             AppLocalizations.of(context)!.unblock,
      //             maxLines: 1,
      //             style: TextStyle(
      //               fontSize: 14,
      //               color: Theme.of(context).colorScheme.onSurface,
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
