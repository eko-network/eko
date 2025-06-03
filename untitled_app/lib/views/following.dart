import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/providers/user_provider.dart';
import 'package:untitled_app/widgets/infinite_scrolly.dart';
import 'package:untitled_app/widgets/shimmer_loaders.dart';
import '../widgets/user_card.dart';
import '../utilities/constants.dart' as c;

class Following extends ConsumerStatefulWidget {
  final String uid;
  const Following({required this.uid, super.key});
  @override
  ConsumerState<Following> createState() => _FollowingState();
}

class _FollowingState extends ConsumerState<Following> {
  Future<(List<MapEntry<String, Never?>>, bool)> getter(
      List<MapEntry<String, Never?>> data, List<String> fullFollowing) async {
    // // value form constants
    const chunkSize = c.usersOnSearch;
    // // this is just to put queries in while they are waiting to finish
    final List<Future<dynamic>> futures = [];
    // // list of uids to render next
    final List<MapEntry<String, Never?>> returnData = [];
    final currentDataSet = data.map((item) => item.key).toSet();
    var unfetchedFollowing =
        fullFollowing.where((e) => !currentDataSet.contains(e)).toList();
    final end = unfetchedFollowing.length < chunkSize
        ? unfetchedFollowing.length
        : chunkSize;
    for (int i = 0; i < end; i++) {
      final future = ref.read(userProvider(unfetchedFollowing[i]).future);
      returnData.add(MapEntry(unfetchedFollowing[i], null));
      futures.add(future);
    }
    await Future.wait(futures);
    return (returnData, unfetchedFollowing.length < chunkSize);
  }

  Future<void> onRefresh() async {
    return await ref.refresh(userProvider(widget.uid));
  }

  @override
  Widget build(BuildContext context) {
    final asyncUser = ref.watch(userProvider(widget.uid));

    return switch (asyncUser) {
      AsyncData(:final value) => Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
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
          body: InfiniteScrolly<String, Never?>(
            getter: (data) => getter(data, value.following),
            widget: (uid) => UserCard(uid: uid),
            initialLoadingWidget: UserLoader(
              length: 12,
            ),
          )),
      AsyncError(:final error) => Center(child: Text('Error: $error')),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}
