import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/types/activity.dart';
part '../generated/providers/activity_provider.g.dart';

@riverpod
class Activity extends _$Activity {
  Timer? _disposeTimer;
  @override
  FutureOr<ActivityModel> build(String id) async {
    // *** This block is for lifecycle management *** //
    // Keep provider alive
    final link = ref.keepAlive();
    ref.onCancel(() {
      // Start a 3-minute countdown when the last listener goes away
      _disposeTimer = Timer(const Duration(minutes: 3), () {
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
    // await Future.delayed(Duration(seconds: 100));
    final cacheValue = ref.read(activityPoolProvider).getItem(id);
    if (cacheValue != null) {
      return cacheValue;
    }

    return _fetchActivityModel(id);
  }

  Future<ActivityModel> _fetchActivityModel(String id) async {
    final actData = await FirebaseFirestore.instance
        .collection('users')
        .doc(ref.watch(currentUserProvider).uid)
        .collection('newActivity')
        .doc(id)
        .get();
    if (actData.data() == null) {
      throw Exception('Failed to load');
    }

    return ActivityModel.fromFirestoreDoc(actData);
  }
}
