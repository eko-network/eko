import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/follow_info_provider.dart';
import 'package:eko_app/providers/pool_providers.dart';
import 'package:eko_app/types/user.dart';
import 'package:eko_app/utilities/supabase_ref.dart';

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

    if (ref.watch(currentUserProvider).user.uid == uid) {
      return ref.watch(currentUserProvider).user;
    }

    final cacheValue = ref.read(userPoolProvider).getItem(uid);
    if (cacheValue != null) {
      return cacheValue;
    }
    return _fetchUserModel(uid);
  }

  Future<UserModel> _fetchUserModel(String uid) async {
    try {
      final response = await supabase.rpc(
        'get_user_by_id',
        params: {'p_uid': uid},
      );
      if (response is! List || response.isEmpty) {
        return UserModel.userNotFound();
      }
      final row = response.first;
      if (row is! Map) return UserModel.userNotFound();
      return UserModel.fromJson(Map<String, dynamic>.from(row));
    } catch (_) {
      return UserModel.userNotFound();
    }
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
    final user = state.value;
    if (user == null || _isFollowAction) {
      return;
    }
    _isFollowAction = true;
    try {
      state = AsyncData(user.copyWith(isFollowing: isFollow));
      await supabase.rpc(
        'change_follow_state',
        params: {'p_uid': user.uid, 'p_is_follow': isFollow},
      );
      ref.invalidate(followInfoProvider(user.uid));
      final actorUid = ref.read(currentUserProvider).user.uid;
      if (actorUid.isNotEmpty && actorUid != user.uid) {
        ref.invalidate(followInfoProvider(actorUid));
      }
    } catch (e) {
      state = AsyncData(user);
    }
    _isFollowAction = false;
  }
}
