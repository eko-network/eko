import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/providers/group_provider.dart';
import 'package:untitled_app/providers/user_provider.dart';
import 'package:untitled_app/widgets/infinite_scrolly.dart';
import 'package:untitled_app/widgets/loading_spinner.dart';
import 'package:untitled_app/widgets/shimmer_loaders.dart';
import '../widgets/user_card.dart';
import '../utilities/constants.dart' as c;

class EditGroup extends ConsumerWidget {
  final String id;
  const EditGroup({required this.id, super.key});

// FIXME change variable names
  Future<(List<(String, Never?)>, bool)> getter(List<(String, Never?)> data,
      List<String> fullFollowers, WidgetRef ref) async {
    // // value form constants
    const chunkSize = c.usersOnSearch;
    // // this is just to put queries in while they are waiting to finish
    final List<Future<dynamic>> futures = [];
    // // list of uids to render next
    final List<(String, Never?)> returnData = [];
    final currentDataSet = data.map((item) => item.$1).toSet();
    var unfetchedFollowers =
        fullFollowers.where((e) => !currentDataSet.contains(e)).toList();
    final end = unfetchedFollowers.length < chunkSize
        ? unfetchedFollowers.length
        : chunkSize;
    for (int i = 0; i < end; i++) {
      final future = ref.read(userProvider(unfetchedFollowers[i]).future);
      returnData.add((unfetchedFollowers[i], null));
      futures.add(future);
    }
    await Future.wait(futures);
    return (returnData, unfetchedFollowers.length < chunkSize);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
    final asyncGroup = ref.watch(groupProvider(id));

    return Scaffold(
        body: asyncGroup.when(
      data: (group) =>
          // Padding(
          //      padding: EdgeInsets.only(left: height * 0.02, right: height * 0.02),
          //      child:
          InfiniteScrolly<String, Never?>(
              appBar: SliverAppBar(
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_rounded,
                      color: Theme.of(context).colorScheme.onSurface),
                  onPressed: () => context.pop(),
                ),
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
              header: Column(children: [
                (group.icon != '')
                    ? SizedBox(
                        width: width * 0.4,
                        height: width * 0.4,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            group.icon,
                            style: TextStyle(fontSize: width * 0.15),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        width: width * 0.3,
                        height: width * 0.3,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            group.name[0],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: width * 0.15,
                            ),
                          ),
                        ),
                      ),
                //FIXME: how can i get there to be less padding between the emoji and title
                Text(
                  group.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person_add_outlined),
                      color: Theme.of(context).colorScheme.onSurface,
                      onPressed: () async {
                        await context.push(
                            '/groups/sub_group/${group.id}/edit_group/add_people');
                      },
                    ),
                    // IconButton(
                    //   icon: const Icon(Icons.notifications_none),
                    //   color: Theme.of(context).colorScheme.onSurface,
                    //   onPressed: () {
                    //     // TODO
                    //   },
                    // ),
                    IconButton(
                      icon: const Icon(Icons.exit_to_app_rounded),
                      color: Theme.of(context).colorScheme.onSurface,
                      onPressed: () async {
                        await ref
                            .read(groupProvider(id).notifier)
                            .leaveGroup(group.id, group.members);
                        if (context.mounted) {
                          context.pop();
                          context.pop();
                        }
                      },
                    ),
                  ],
                ),
              ]),
              getter: (data) => getter(data, group.members, ref),
              widget: (uid) => UserCard(uid: uid),
              onRefresh: () async => await ref.refresh(groupProvider(id)),
              initialLoadingWidget: UserLoader(
                length: 12,
                // ),
              )),
      loading: () => Center(child: LoadingSpinner()),
      error: (_, __) =>
          _ErrorMessage(message: AppLocalizations.of(context)!.groupNotFound),
    ));
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;
  const _ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: width * 0.8,
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 23),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: width * 0.45,
            height: width * 0.15,
            child: TextButton(
              onPressed: () => context.go('/feed'),
              style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary),
              child: Text(
                AppLocalizations.of(context)!.exit,
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 1,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
