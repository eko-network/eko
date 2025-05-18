import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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
    final data =
        await FirebaseFirestore.instance.collection('groups').doc(id).get();
    final postData = data.data();
    if (postData == null) {
      throw Exception('Failed to load');
    }

    return GroupModel.fromFirestore(postData, data.id);
  }

  Future<String> createGroup(GroupModel group) async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('groups').add(group.toJson());
    return snapshot.id;
  }

  Future<void> updateGroupMembers(
      GroupModel group, List<String> members) async {
    final firestore = FirebaseFirestore.instance;

    // Get the first document (there should be only one)

    // Update the 'members' field in the document
    await firestore.collection('groups').doc(group.id).update({
      'members': members,
    });

    //print('Group members updated successfully.');
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

  // Future<PaginationGetterReturn> getGroups(dynamic time) async {
  //   final user = FirebaseAuth.instance.currentUser!.uid;
  //   final query = FirebaseFirestore.instance
  //       .collection('groups')
  //       .where('members', arrayContains: user)
  //       .orderBy('lastActivity', descending: true);
  //   //.where("author", isEqualTo: user)

  //   late QuerySnapshot<Map<String, dynamic>> snapshot;
  //   if (time == null) {
  //     //initial data
  //     snapshot = await query.limit(c.postsOnRefresh).get();
  //   } else {
  //     snapshot = await query.startAfter([time]).limit(c.postsOnRefresh).get();
  //   }
  //   final postList = snapshot.docs.map<GroupModel>((doc) {
  //     var data = doc.data();

  //     return GroupModel.fromFirestore(data, doc.id);
  //   }).toList();
  //   return PaginationGetterReturn(
  //       end: (postList.length < c.postsOnRefresh), payload: postList);
  // }
}
