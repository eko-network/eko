import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/auth_provider.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/types/user.dart';
import 'package:untitled_app/utilities/supabase_ref.dart';
// Necessary for code-generation to work
part '../generated/providers/user_provider.g.dart';

@riverpod
class User extends _$User {
  Timer? _disposeTimer;
  bool _isFollowAction = false;
  @override
  FutureOr<UserModel> build(String uid) {
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
      return ref.watch(currentUserProvider)!;
    }

    final cacheValue = ref.read(userPoolProvider).getItem(uid);
    if (cacheValue != null) {
      return cacheValue;
    }
    return _fetchUserModel(uid);
  }

  Future<UserModel> _fetchUserModel(String uid) async {
    final List response =
        await supabase.rpc('get_user_by_id', params: {'p_uid': uid});
    return UserModel.fromJson(response.first);
  }

  Future<void> toggleFollow() async {
    (await future).isFollowing ? await unfollow() : await follow();
  }

  Future<void> follow() async {
    await _followInner(true);
  }

  Future<void> unfollow() async {
    await _followInner(false);
  }

  Future<void> _followInner(bool isFollow) async {
    final user = state.valueOrNull;
    if (user == null || _isFollowAction) {
      return;
    }
    _isFollowAction = true;
    try {
      state = AsyncData(user.copyWith(isFollowing: isFollow));
      await supabase.rpc('change_follow_state',
          params: {'p_uid': user.uid, 'p_is_follow': isFollow});
    } catch (e) {
      state = AsyncData(user);
    }
    _isFollowAction = false;
  }
}
