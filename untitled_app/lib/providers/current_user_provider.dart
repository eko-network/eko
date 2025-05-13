import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/models/post_handler.dart';
import 'package:untitled_app/providers/auth_provider.dart';
import 'package:untitled_app/types/current_user.dart';
import 'package:untitled_app/utilities/enums.dart';
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
    final likes = [...state.likedPosts];
    likes.add(id);
    state = state.copyWith(likedPosts: likes);
  }

  void removeIdFromLiked(String id) {
    final likes = [...state.likedPosts];
    likes.remove(id);
    state = state.copyWith(likedPosts: likes);
  }

  void addIdToDisliked(String id) {
    final dislikes = [...state.likedPosts];
    dislikes.add(id);
    state = state.copyWith(dislikedPosts: dislikes);
  }

  void removeIdFromDisliked(String id) {
    final dislikes = [...state.likedPosts];
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

  Future<bool> addFollower(String otherUid) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final uid = ref.read(authProvider).uid!;
      await Future.wait([
        firestore.collection('users').doc(uid).update({
          'profileData.following': FieldValue.arrayUnion([otherUid])
        }),
        firestore.collection('users').doc(otherUid).update({
          'profileData.followers': FieldValue.arrayUnion([uid])
        }),
        // TODO: change this later
        locator<PostsHandling>().addActivty(
            type: 'follow',
            content: 'Someone followed you',
            path: uid,
            user: otherUid)
      ]);

      state.user.following.add(otherUid);
      return true;
    } catch (e) {
      return false;
    }
  }

  LikeState getLikeState(String postId) {
    final liked = state.likedPosts.contains(postId);
    final disliked = state.dislikedPosts.contains(postId);
    if (liked && disliked) {
      //TODO this case should not happen. Maybe write a function to correct db state?
      return LikeState.isLiked;
    }
    if (liked) {
      return LikeState.isLiked;
    }
    if (disliked) {
      return LikeState.isDisliked;
    }
    return LikeState.neutral;
  }

  Future<bool> removeFollower(String otherUid) async {
    try {
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

      state.user.following.remove(otherUid);
      return true;
    } catch (e) {
      return false;
    }
  }
}
