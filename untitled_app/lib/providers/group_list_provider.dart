import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/types/group.dart';
import '../utilities/constants.dart' as c;
part '../generated/providers/group_list_provider.g.dart';

@riverpod
class GroupList extends _$GroupList {
  final List<String> _timestamps = [];
  Timer? _disposeTimer;
  @override
  (List<String>, bool) build() {
    // keeping this alive for a little make the compose page feel better
    // *** This block is for lifecycle management *** //
    // Keep provider alive
    final link = ref.keepAlive();
    ref.onCancel(() {
      // Start a 3-minute countdown when the last listener goes away
      _disposeTimer = Timer(const Duration(minutes: 1), () {
        link.close();
      });
    });
    ref.onResume(() {
      // Cancel the timer if a listener starts again
      _disposeTimer?.cancel();
    });
    ref.onDispose(() {
      // ckean up if the provider is somehow disposed
      _disposeTimer?.cancel();
    });
    // ********************************************* //
    return ([], false);
  }

  Future<void> getter() async {
    final user = FirebaseAuth.instance.currentUser!.uid;
    final baseQuery = FirebaseFirestore.instance
        .collection('groups')
        .where('members', arrayContains: user)
        .orderBy('lastActivity', descending: true)
        .limit(c.postsOnRefresh);
    final query =
        state.$1.isEmpty ? baseQuery : baseQuery.startAfter([_timestamps.last]);

    final groupList = (await query.get()).docs.map(
      (doc) {
        return GroupModel.fromFirestoreDoc(doc);
      },
    );

    ref.read(groupPoolProvider).putAll(groupList);
    final newList = [...state.$1];
    for (final group in groupList) {
      newList.add(group.id);
      _timestamps.add(group.createdOn);
    }
    state = (newList, groupList.length < c.postsOnRefresh);
  }

  Future<void> refresh() async {
    _timestamps.clear();
    state = ([], false);
    await getter();
  }
}
