import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> setGroupMembers(String id, List<String> members) async {
  final firestore = FirebaseFirestore.instance;
  await firestore.collection('groups').doc(id).update({'members': members});
}

Future<void> removeFromNotSeenGroup(String id, String uid) async {
  final firestore = FirebaseFirestore.instance;
  await firestore.collection('groups').doc(id).update({
    'notSeen': FieldValue.arrayRemove([uid]),
  });
}
