import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../generated/providers/restricted_user_provider.g.dart';

@Riverpod(keepAlive: true)
class RestrictedUser extends _$RestrictedUser {
  @override
  Future<List<String>> build() async {
    final doc = await FirebaseFirestore.instance
        .collection('utilities')
        .doc('restrictedUsers')
        .get();

    if (doc.exists && doc.data() != null && doc.data()!.containsKey('users')) {
      return List<String>.from(doc.data()!['users'] as List);
    }
    return [];
  }
}
