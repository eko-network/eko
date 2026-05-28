import 'dart:io';

import 'package:flutter/material.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eko_app/interfaces/user.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/types/current_user.dart';
import 'package:eko_app/utilities/supabase_ref.dart';

part '../generated/providers/current_user_provider.g.dart';

class NeedsProfileSetupNotifier extends Notifier<bool> {
  @override
  bool build() => false;
}

final needsProfileSetupProvider =
    NotifierProvider<NeedsProfileSetupNotifier, bool>(
  NeedsProfileSetupNotifier.new,
);

@Riverpod(keepAlive: true)
class CurrentUser extends _$CurrentUser {
  @override
  // This is nullable instead of async so that we can just bang it. Await will happen inside the require auth widget.
  CurrentUserModel build() {
    ref.listen(authProvider, (previous, next) {
      final prevUid = previous?.uid;
      final nextUid = next.uid;
      if (prevUid == nextUid) {
        return;
      }
      if (nextUid == null) {
        state = CurrentUserModel.loading();
      } else {
        reload();
      }
    });

    final auth = ref.read(authProvider);
    if (auth.uid != null) {
      reload();
    }
    return CurrentUserModel.loading();
  }

  Future<void> editProfile({
    String? name,
    String? bio,
    String? username,
    File? profilePicture,
  }) async {
    final prev = state.user;
    final nextName = name ?? prev.name;
    final nextBio = bio ?? prev.bio;
    final nextUsername = username ?? prev.username;
    state = state.copyWith(
      user: state.user.copyWith(
        name: nextName,
        bio: nextBio,
        username: nextUsername,
      ),
    );

    try {
      String? pic;
      if (profilePicture != null) {
        pic = await _uploadProfilePicture(profilePicture);
        if (pic == null) {
          throw Exception('profile_picture_upload_failed');
        }
        state = state.copyWith(user: state.user.copyWith(profilePicture: pic));
      }

      final response = await supabase.rpc(
        'update_profile',
        params: {
          'p_name': name,
          'p_bio': bio,
          'p_username': username,
          'p_profile_picture': pic,
        },
      );
      if (response is! List || response.isEmpty) {
        throw Exception('unknown');
      }
      final row = Map<String, dynamic>.from(response.first);
      if (row['success'] != true) {
        throw Exception(row['error_message'] ?? 'unknown');
      }

      state = state.copyWith(
        user: state.user.copyWith(
          name: (row['name'] ?? state.user.name) as String,
          bio: (row['bio'] ?? state.user.bio) as String,
          username: (row['username'] ?? state.user.username) as String,
          profilePicture:
              (row['profile_picture'] ?? state.user.profilePicture) as String,
          isVerified: (row['is_verified'] ?? state.user.isVerified) as bool,
        ),
      );

      final userData = <String, dynamic>{
        'name': state.user.name,
        'bio': state.user.bio,
        'username': state.user.username,
      };
      if (state.user.profilePicture.isNotEmpty) {
        userData['profile_picture'] = state.user.profilePicture;
      }
      try {
        await supabase.auth.updateUser(UserAttributes(data: userData));
      } catch (e) {
        debugPrint('editProfile auth metadata update error: $e');
      }
    } catch (e) {
      state = state.copyWith(user: prev);
      rethrow;
    }
  }

  Future<String?> _uploadProfilePicture(File img) async {
    final uid = state.user.uid;
    try {
      final bytes = await img.readAsBytes();
      final storage = supabase.storage.from('profile_pictures');
      final path = '$uid/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await storage.uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );
      try {
        final files = await storage.list(path: uid);
        final oldPaths = files
            .map((file) => file.name)
            .where((name) => '$uid/$name' != path)
            .map((name) => '$uid/$name')
            .toList();
        if (oldPaths.isNotEmpty) {
          await storage.remove(oldPaths);
        }
      } catch (_) {}
      final url = storage.getPublicUrl(path);
      return url;
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    final stateUid = state.user.uid;
    final authUid = ref.read(authProvider).uid;
    final uid = stateUid.isNotEmpty ? stateUid : (authUid ?? '');
    if (uid.isNotEmpty) {
      await removeDeviceNotificationToken(uid);
    }
    await supabase.auth.signOut();
  }

  Future<List<String>> _getPeopleWhoBlockedMe() async {
    try {
      final uid = ref.read(authProvider).uid!;
      final rows = await supabase
          .from('blocked')
          .select('source_uid')
          .eq('target_uid', uid);
      return (rows as List).map((r) => r['source_uid'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> blockUser(String uid) async {
    state = state.copyWith(blockedUsers: <String>{...state.blockedUsers, uid});
    try {
      await supabase.from('blocked').insert({
        'source_uid': state.user.uid,
        'target_uid': uid,
      });
    } catch (e) {
      final blocked = <String>{...state.blockedUsers};
      blocked.remove(uid);
      state = state.copyWith(blockedUsers: blocked);
    }
    await _unfollowUser(uid);
  }

  Future<void> unBlockUser(String uid) async {
    final blocked = <String>{...state.blockedUsers};
    blocked.remove(uid);
    state = state.copyWith(blockedUsers: blocked);
    try {
      await supabase
          .from('blocked')
          .delete()
          .eq('source_uid', state.user.uid)
          .eq('target_uid', uid);
    } catch (e) {
      state = state.copyWith(
        blockedUsers: <String>{...state.blockedUsers, uid},
      );
    }
  }

  Future<void> reload() async {
    final uid = ref.read(authProvider).uid;
    if (uid == null) return;
    try {
      final response = await supabase.rpc(
        'get_user_by_id',
        params: {'p_uid': uid},
      );
      if (response is! List || response.isEmpty) {
        final currentUser = supabase.auth.currentUser;
        final provider = currentUser?.appMetadata['provider'] as String?;
        final identities = currentUser?.identities ?? [];
        final isOAuth = provider == 'google' ||
            identities.any((i) => i.provider == 'google');
        if (isOAuth) {
          ref.read(needsProfileSetupProvider.notifier).state = true;
        } else {
          await signOut();
        }
        return;
      }
      final first = response.first;
      if (first is! Map) {
        await signOut();
        return;
      }
      final row = Map<String, dynamic>.from(first);
      final username = row['username'] as String? ?? '';
      if (username.isEmpty) {
        ref.read(needsProfileSetupProvider.notifier).state = true;
        return;
      }
      final blockedBy = await _getPeopleWhoBlockedMe();
      row['blocked_by'] = blockedBy;
      state = CurrentUserModel.fromJson(row);
      ref.read(authProvider.notifier).registerNotificationsIfNeeded();
    } catch (e) {
      debugPrint('Error reloading current user from Supabase: $e');
    }
  }

  Future<void> _unfollowUser(String otherUid) async {
    try {
      final updatedFollowing =
          state.user.following.where((id) => id != otherUid).toList();
      state = state.copyWith(
        user: state.user.copyWith(following: updatedFollowing),
      );
      final userState = ref.read(userProvider(otherUid));
      userState.whenData((otherUser) {
        final updatedFollowers =
            otherUser.followers.where((id) => id != state.user.uid).toList();
        ref
            .read(userProvider(otherUid).notifier)
            .updateFollowers(updatedFollowers);
      });

      await supabase.rpc(
        'change_follow_state',
        params: {'p_uid': otherUid, 'p_is_follow': false},
      );
    } catch (e) {
      final revertedFollowing = [...state.user.following, otherUid];
      state = state.copyWith(
        user: state.user.copyWith(following: revertedFollowing),
      );
      final userState = ref.read(userProvider(otherUid));
      userState.whenData((otherUser) {
        if (!otherUser.followers.contains(state.user.uid)) {
          final revertedFollowers = [...otherUser.followers, state.user.uid];
          ref
              .read(userProvider(otherUid).notifier)
              .updateFollowers(revertedFollowers);
        }
      });
    }
  }
}
