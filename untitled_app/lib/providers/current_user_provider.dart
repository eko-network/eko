import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/models/post_handler.dart';
import 'package:untitled_app/providers/auth_provider.dart';
import 'package:untitled_app/providers/user_provider.dart';
import 'package:untitled_app/types/current_user.dart';
import 'package:untitled_app/utilities/locator.dart';
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

  void addIdToLiked(String id) {
    final likes = Set<String>.from(state.likedPosts);
    likes.add(id);
    state = state.copyWith(likedPosts: likes);
  }

  void removeIdFromLiked(String id) {
    final likes = Set<String>.from(state.likedPosts);
    likes.remove(id);
    state = state.copyWith(likedPosts: likes);
  }

  void addIdToDisliked(String id) {
    final dislikes = Set<String>.from(state.dislikedPosts);
    dislikes.add(id);
    state = state.copyWith(dislikedPosts: dislikes);
  }

  void removeIdFromDisliked(String id) {
    final dislikes = Set<String>.from(state.dislikedPosts);
    dislikes.remove(id);
    state = state.copyWith(dislikedPosts: dislikes);
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

  Future<bool> blockUser(String blockedUid) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final uid = ref.read(authProvider).uid!;
      await firestore.collection('users').doc(uid).update({
        'blockedUsers': FieldValue.arrayUnion([blockedUid])
      });

      state.blockedBy.add(blockedUid);

      removeFollower(blockedUid);
      return true;
    } catch (e) {
      return false;
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

  Future<void> addFollower(String otherUid) async {
    try {
      // Update state of current user and other user
      final updatedFollowing = [...state.user.following, otherUid];
      state = state.copyWith(
          user: state.user.copyWith(following: updatedFollowing));
      final userState = ref.read(userProvider(otherUid));
      userState.whenData((otherUser) {
        if (!otherUser.followers.contains(state.user.uid)) {
          final updatedFollowers = [...otherUser.followers, state.user.uid];
          ref
              .read(userProvider(otherUid).notifier)
              .updateFollowers(updatedFollowers);
        }
      });

      // Update database
      final firestore = FirebaseFirestore.instance;
      final uid = ref.read(authProvider).uid!;
      await Future.wait([
        firestore.collection('users').doc(uid).update({
          'profileData.following': FieldValue.arrayUnion([otherUid])
        }),
        firestore.collection('users').doc(otherUid).update({
          'profileData.followers': FieldValue.arrayUnion([uid])
        }),
        locator<PostsHandling>().addActivty(
            type: 'follow',
            content: 'Someone followed you',
            path: uid,
            user: otherUid)
      ]);
    } catch (e) {
      // Revert state updates on error
      final revertedFollowing =
          state.user.following.where((id) => id != otherUid).toList();
      state = state.copyWith(
          user: state.user.copyWith(following: revertedFollowing));
      final userState = ref.read(userProvider(otherUid));
      userState.whenData((otherUser) {
        final revertedFollowers =
            otherUser.followers.where((id) => id != state.user.uid).toList();
        ref
            .read(userProvider(otherUid).notifier)
            .updateFollowers(revertedFollowers);
      });
    }
  }

  Future<void> removeFollower(String otherUid) async {
    try {
      // Update state of current user and other user
      final updatedFollowing =
          state.user.following.where((id) => id != otherUid).toList();
      state = state.copyWith(
          user: state.user.copyWith(following: updatedFollowing));
      final userState = ref.read(userProvider(otherUid));
      userState.whenData((otherUser) {
        final updatedFollowers =
            otherUser.followers.where((id) => id != state.user.uid).toList();
        ref
            .read(userProvider(otherUid).notifier)
            .updateFollowers(updatedFollowers);
      });

      // Update database
      final firestore = FirebaseFirestore.instance;
      final uid = ref.read(authProvider).uid!;
      await Future.wait([
        firestore.collection('users').doc(uid).update({
          'profileData.following': FieldValue.arrayRemove([otherUid])
        }),
        firestore.collection('users').doc(otherUid).update({
          'profileData.followers': FieldValue.arrayRemove([uid])
        })
      ]);
    } catch (e) {
      // Revert state updates on error
      final revertedFollowing = [...state.user.following, otherUid];
      state = state.copyWith(
          user: state.user.copyWith(following: revertedFollowing));
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
