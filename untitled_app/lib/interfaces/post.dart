import 'package:cloud_firestore/cloud_firestore.dart';

Future<int> countComments(String postId) {
  return FirebaseFirestore.instance
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .count()
      .get()
      .then((value) => value.count ?? 0, onError: (e) => 0);
}
