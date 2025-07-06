import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/current_user_provider.dart';
import '../providers/post_provider.dart';

Future<void> addReport(WidgetRef ref, int id, String message) async {
  final firestore = FirebaseFirestore.instance;
  final uid = ref.read(currentUserProvider).uid;
  final post = await ref.read(postProvider(id).future);

  final report = {
    'sender': uid,
    'postId': id,
    'postAuthor': post.uid,
    'message': message,
    'time': DateTime.now().toUtc().toIso8601String()
  };

  await firestore.collection('reports').add(report);
}
