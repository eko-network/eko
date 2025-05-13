import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/auth_provider.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/user_pool_provider.dart';
import 'package:untitled_app/types/user.dart';
// Necessary for code-generation to work
part '../generated/providers/user_provider.g.dart';

@riverpod
class User extends _$User {
  Timer? _disposeTimer;
  @override
  Future<UserModel> build(String uid) async {
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

    if (ref.watch(authProvider).uid == uid) {
      return UserModel.fromCurrent(ref.watch(currentUserProvider)!);
    }
    final cacheValue = ref.read(userPoolProvider).getItem(uid);
    if (cacheValue != null) {
      return cacheValue;
    }

    final userRef = FirebaseFirestore.instance.collection('users');
    final data = await userRef.doc(uid).get();
    return UserModel.fromJson(data.data());
  }
}
