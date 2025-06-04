import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/types/activity.dart';
import 'package:untitled_app/utilities/constants.dart' as c;
import 'package:untitled_app/widgets/infinite_scrolly.dart';
import 'package:untitled_app/widgets/recent_activity_card.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/widgets/shimmer_loaders.dart';

class RecentActivity extends ConsumerWidget {
  const RecentActivity({super.key});

  Future<(List<MapEntry<String, String>>, bool)> getter(
      List<MapEntry<String, String>> list, WidgetRef ref) async {
    final uid = ref.read(currentUserProvider).user.uid;
    final baseQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('newActivity')
        .orderBy('time', descending: true)
        .where('type',
            whereIn: const ['comment', 'follow', 'tag']) //update for new types
        .limit(c.activitiesPerRequest);
    final query =
        list.isEmpty ? baseQuery : baseQuery.startAfter([list.last.value]);

    final activityList = await query.get().then(
        (data) => data.docs.map((doc) => ActivityModel.fromFirestoreDoc(doc)));
    ref.read(activityPoolProvider).putAll(activityList);
    final retList =
        activityList.map((item) => MapEntry(item.id, item.createdAt)).toList();
    return (retList, retList.length < c.postsOnRefresh);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => context.pop('poped'),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          AppLocalizations.of(context)!.recentActivity,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: InfiniteScrolly<String, String>(
        getter: (data) => getter(data, ref),
        widget: recentActivityCardBuilder,
        initialLoadingWidget: UserLoader(
          length: 12,
        ),
      ),
    );
  }
}
