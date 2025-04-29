import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/auth_provider.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/types/user.dart';
// Necessary for code-generation to work
part '../generated/providers/user_provider.g.dart';

@Riverpod(keepAlive: true)
class User extends _$User {
  @override
  Future<UserModel> build(String uid) async {
    if (ref.watch(authProvider).uid == uid) {
      return UserModel.fromCurrent(ref.watch(currentUserProvider)!);
    }
    final userRef = FirebaseFirestore.instance.collection('users');
    final data = await userRef.doc(uid).get();
    return UserModel.fromJson(data.data());
  }
}
