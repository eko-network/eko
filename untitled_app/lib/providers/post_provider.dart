import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/interfaces/post.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/post_pool_provider.dart';
import 'package:untitled_app/types/post.dart';
import 'package:untitled_app/utilities/enums.dart';
// Necessary for code-generation to work
part '../generated/providers/post_provider.g.dart';

@riverpod
class Post extends _$Post {
  Timer? _disposeTimer;
  bool _isLikeStateChanging = false;
  @override
  Future<PostModel> build(String id) async {
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
    // await Future.delayed(Duration(seconds: 100));
    final cacheValue = ref.read(postPoolProvider).getItem(id);
    if (cacheValue != null) {
      return cacheValue;
    }
    final postsRef = FirebaseFirestore.instance.collection('posts');
    final data = await Future.wait([postsRef.doc(id).get(), countComments(id)]);
    final postData = data[0] as DocumentSnapshot<Map<String, dynamic>>;
    final commentCount = data[1] as int;

    if (postData.data() == null) {
      throw Exception('Failed to load');
    }

    final json = postData.data()!;
    json['id'] = id;
    json['commentCount'] = commentCount;

    return PostModel.fromJson(
        json, ref.read(currentUserProvider.notifier).getLikeState(id));
  }

  Future<void> _addLikeUnsafe(String id) async {
    final firestore = FirebaseFirestore.instance;
    final user = ref.read(currentUserProvider).user.uid;
    await Future.wait([
      firestore.collection('users').doc(user).update({
        'profileData.likedPosts': FieldValue.arrayUnion([id])
      }),
      firestore
          .collection('posts')
          .doc(id)
          .update({'likes': FieldValue.increment(1)})
    ]);
  }

  Future<void> addLike() async {
    if (_isLikeStateChanging) {
      return;
    }
    final prevState = await future;
    if (prevState.likeState == LikeState.isLiked) {
      return;
    }
    _isLikeStateChanging = true;
    try {
      state = AsyncData(prevState.copyWith(
          likeState: LikeState.isLiked, likes: prevState.likes + 1));
      await _addLikeUnsafe(prevState.id);
      ref.read(currentUserProvider.notifier).addIdToLiked(prevState.id);
    } catch (e) {
      state = AsyncData(prevState);
      ref.read(currentUserProvider.notifier).removeIdFromLiked(prevState.id);
    }
    _isLikeStateChanging = false;
  }

  Future<void> _removeLikeUnsafe(String id) async {
    final firestore = FirebaseFirestore.instance;
    final user = ref.read(currentUserProvider).user.uid;
    await Future.wait([
      firestore.collection('users').doc(user).update({
        'profileData.likedPosts': FieldValue.arrayRemove([id])
      }),
      firestore
          .collection('posts')
          .doc(id)
          .update({'likes': FieldValue.increment(-1)}),
    ]);
  }

  Future<void> removeLike() async {
    if (_isLikeStateChanging) {
      return;
    }
    final prevState = await future;
    if (prevState.likeState != LikeState.isLiked) {
      return;
    }
    _isLikeStateChanging = true;
    try {
      state = AsyncData(prevState.copyWith(
          likeState: LikeState.neutral, likes: prevState.likes - 1));
      await _removeLikeUnsafe(prevState.id);
      ref.read(currentUserProvider.notifier).addIdToLiked(prevState.id);
    } catch (e) {
      state = AsyncData(prevState);
      ref.read(currentUserProvider.notifier).removeIdFromLiked(prevState.id);
    }
    _isLikeStateChanging = false;
  }

  Future<void> _addDislikeUnsafe(String id) async {
    final firestore = FirebaseFirestore.instance;
    final user = ref.read(currentUserProvider).user.uid;
    await Future.wait([
      firestore.collection('users').doc(user).update({
        'profileData.dislikedPosts': FieldValue.arrayUnion([id])
      }),
      firestore
          .collection('posts')
          .doc(id)
          .update({'dislikes': FieldValue.increment(1)})
    ]);
  }

  Future<void> addDislike() async {
    if (_isLikeStateChanging) {
      return;
    }
    final prevState = await future;
    if (prevState.likeState == LikeState.isDisliked) {
      return;
    }
    _isLikeStateChanging = true;
    try {
      state = AsyncData(prevState.copyWith(
          likeState: LikeState.isDisliked, dislikes: prevState.dislikes + 1));
      await _addDislikeUnsafe(prevState.id);
      ref.read(currentUserProvider.notifier).addIdToDisliked(prevState.id);
    } catch (e) {
      state = AsyncData(prevState);
      ref.read(currentUserProvider.notifier).removeIdFromDisliked(prevState.id);
    }
    _isLikeStateChanging = false;
  }

  Future<void> _removeDisikeUnsafe(String id) async {
    final firestore = FirebaseFirestore.instance;
    final user = ref.read(currentUserProvider).user.uid;
    await Future.wait([
      firestore.collection('users').doc(user).update({
        'profileData.dislikedPosts': FieldValue.arrayRemove([id])
      }),
      firestore
          .collection('posts')
          .doc(id)
          .update({'dislikes': FieldValue.increment(-1)}),
    ]);
  }

  Future<void> removeDislike() async {
    if (_isLikeStateChanging) {
      return;
    }
    final prevState = await future;
    if (prevState.likeState != LikeState.isDisliked) {
      return;
    }
    _isLikeStateChanging = true;
    try {
      state = AsyncData(prevState.copyWith(
          likeState: LikeState.neutral, dislikes: prevState.dislikes - 1));
      await _removeDisikeUnsafe(prevState.id);
      ref.read(currentUserProvider.notifier).addIdToDisliked(prevState.id);
    } catch (e) {
      state = AsyncData(prevState);
      ref.read(currentUserProvider.notifier).removeIdFromDisliked(prevState.id);
    }
    _isLikeStateChanging = false;
  }
}
