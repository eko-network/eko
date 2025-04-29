import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/auth_provider.dart';
import 'package:untitled_app/types/current_user.dart';
// Necessary for code-generation to work
part '../generated/providers/current_user_provider.g.dart';

@Riverpod(keepAlive: true)
class CurrentUser extends _$CurrentUser {
  @override
  // This is nullable instead of async so that we can just bang it. Await will happen inside the require auth widget.
  CurrentUserModel build() {
    final auth = ref.watch(authProvider);
    // If uid is null, wait for authProvider to emit a non-null uid
    if (auth.uid != null) {
      reload();
    }
    return CurrentUserModel.loading();
  }

  Future<List<String>> _getPeopleWhoBlockedMe() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final user = ref.read(authProvider).uid!;
      final querySnapshot = await firestore
          .collection('users')
          .where('blockedUsers', arrayContains: user)
          .get();
      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> reload() async {
    final uid = ref.read(authProvider).uid!;
    final userRef = FirebaseFirestore.instance.collection('users');
    final results =
        await Future.wait([userRef.doc(uid).get(), _getPeopleWhoBlockedMe()]);
    final mainData =
        (results[0] as DocumentSnapshot<Map<String, dynamic>>).data();
    assert(mainData != null);
    mainData!['blockedBy'] = results[1];

    state = CurrentUserModel.fromJson(mainData);
  }
}
