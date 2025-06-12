import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/interfaces/groups.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/group_list_provider.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/types/group.dart';
// Necessary for code-generation to work
part '../generated/providers/group_provider.g.dart';

@riverpod
class Group extends _$Group {
  Timer? _disposeTimer;
  @override
  Future<GroupModel> build(String id) async {
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
    final cacheValue = ref.read(groupPoolProvider).getItem(id);
    if (cacheValue != null) {
      return cacheValue;
    }
    return _fetchGroupModel(id);
  }

  Future<GroupModel> _fetchGroupModel(String id) async {
    final data =
        await FirebaseFirestore.instance.collection('groups').doc(id).get();
    final postData = data.data();
    if (postData == null) {
      throw Exception('Failed to load');
    }
    return GroupModel.fromFirestore(postData, data.id);
  }

  Future<void> updateGroupMembers(List<String> members) async {
    await setGroupMembers(id, members);
    final previousState = await future;
    state = AsyncData(previousState.copyWith(members: members));
  }

  Future<void> leaveGroup(String id, List<String> members) async {
    final updatedMembers = List<String>.from(members);
    updatedMembers.remove(ref.read(currentUserProvider).user.uid);

    final previousState = await future;
    await setGroupMembers(id, updatedMembers);
    state = AsyncData(previousState.copyWith(members: updatedMembers));
    ref.read(groupListProvider.notifier).removeGroupById(id);
  }

  Future<void> toggleUnread(bool toggle) async {
    // TODO Christian: jank. need to rethought with the sub group controller stuff
    if (toggle == false) {
      state.whenData((group) {
        group.notSeen.remove(ref.read(currentUserProvider).user.uid);
        state = AsyncData(group.copyWith(notSeen: group.notSeen));
      });
    }
  }

  Future<GroupModel?> getGroupFromId(String id) async {
    final data =
        await FirebaseFirestore.instance.collection('groups').doc(id).get();
    final postData = data.data();
    if (postData == null) {
      return null;
    }
    return GroupModel.fromFirestore(postData, data.id);
  }
}
