import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/interfaces/post.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/post_pool_provider.dart';
import 'package:untitled_app/types/post.dart';
// Necessary for code-generation to work
part '../generated/providers/post_provider.g.dart';

@riverpod
class Post extends _$Post {
  Timer? _disposeTimer;
  bool _isLiking = false;
  @override
  FutureOr<PostModel> build(String id) async {
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

    return _fetchPostModel(id);
  }

  Future<PostModel> _fetchPostModel(String id) async {
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

    return PostModel.fromJson(json);
  }

  Future<void> _addLikeToDb(String id) async {
    final firestore = FirebaseFirestore.instance;
    final uid = ref.read(currentUserProvider).user.uid;
    await Future.wait([
      firestore.collection('users').doc(uid).update({
        'profileData.likedPosts': FieldValue.arrayUnion([id])
      }),
      firestore
          .collection('posts')
          .doc(id)
          .update({'likes': FieldValue.increment(1)})
    ]);
  }

  Future<void> _removeLikeFromDb(String id) async {
    final firestore = FirebaseFirestore.instance;
    final uid = ref.read(currentUserProvider).user.uid;
    await Future.wait([
      firestore.collection('users').doc(uid).update({
        'profileData.likedPosts': FieldValue.arrayRemove([id])
      }),
      firestore
          .collection('posts')
          .doc(id)
          .update({'likes': FieldValue.increment(-1)}),
    ]);
  }

  Future<void> _addDislikeToDb(String id) async {
    final firestore = FirebaseFirestore.instance;
    final uid = ref.read(currentUserProvider).user.uid;
    await Future.wait([
      firestore.collection('users').doc(uid).update({
        'profileData.dislikedPosts': FieldValue.arrayUnion([id])
      }),
      firestore
          .collection('posts')
          .doc(id)
          .update({'dislikes': FieldValue.increment(1)})
    ]);
  }

  Future<void> _removeDisikeFromDb(String id) async {
    final firestore = FirebaseFirestore.instance;
    final uid = ref.read(currentUserProvider).user.uid;
    await Future.wait([
      firestore.collection('users').doc(uid).update({
        'profileData.dislikedPosts': FieldValue.arrayRemove([id])
      }),
      firestore
          .collection('posts')
          .doc(id)
          .update({'dislikes': FieldValue.increment(-1)}),
    ]);
  }

  Future<void> likePostToggle() async {
    final prevState = await future;
    if (_isLiking) return;
    _isLiking = true;
    // liked -> not liked
    if (ref.read(currentUserProvider).likedPosts.contains(prevState.id)) {
      ref.read(currentUserProvider.notifier).removeIdFromLiked(prevState.id);
      state = AsyncData(prevState.copyWith(likes: prevState.likes - 1));
      try {
        await _removeLikeFromDb(prevState.id);
      } catch (_) {
        ref.read(currentUserProvider.notifier).addIdToLiked(prevState.id);
        state = AsyncData(prevState);
      }
      // not liked -> liked
    } else {
      bool wasDisliked = false;
      final List<Future<void>> ops = [_addLikeToDb(prevState.id)];
      ref.read(currentUserProvider.notifier).addIdToLiked(prevState.id);
      if (ref.read(currentUserProvider).dislikedPosts.contains(prevState.id)) {
        wasDisliked = true;
        ref
            .read(currentUserProvider.notifier)
            .removeIdFromDisliked(prevState.id);
        state = AsyncData(prevState.copyWith(
            dislikes: prevState.dislikes - 1, likes: prevState.likes + 1));
        ops.add(_removeDisikeFromDb(prevState.id));
      } else {
        state = AsyncData(prevState.copyWith(likes: prevState.likes + 1));
      }
      try {
        await Future.wait(ops);
      } catch (_) {
        ref.read(currentUserProvider.notifier).removeIdFromLiked(prevState.id);
        if (wasDisliked) {
          ref.read(currentUserProvider.notifier).addIdToDisliked(prevState.id);
        }
        state = AsyncData(prevState);
      }
    }
    _isLiking = false;
  }

  Future<void> dislikePostToggle() async {
    final prevState = await future;
    if (_isLiking) return;
    _isLiking = true;
    if (ref.read(currentUserProvider).dislikedPosts.contains(prevState.id)) {
      ref.read(currentUserProvider.notifier).removeIdFromDisliked(prevState.id);
      state = AsyncData(prevState.copyWith(dislikes: prevState.dislikes - 1));
      try {
        await _removeDisikeFromDb(prevState.id);
      } catch (_) {
        ref.read(currentUserProvider.notifier).addIdToDisliked(prevState.id);
        state = AsyncData(prevState);
      }
    } else {
      bool wasLiked = false;
      final List<Future<void>> ops = [_addDislikeToDb(prevState.id)];
      ref.read(currentUserProvider.notifier).addIdToDisliked(prevState.id);
      if (ref.read(currentUserProvider).likedPosts.contains(prevState.id)) {
        wasLiked = true;
        ref.read(currentUserProvider.notifier).removeIdFromLiked(prevState.id);
        state = AsyncData(prevState.copyWith(
            likes: prevState.likes - 1, dislikes: prevState.dislikes + 1));
        ops.add(_removeLikeFromDb(prevState.id));
      } else {
        state = AsyncData(prevState.copyWith(dislikes: prevState.dislikes + 1));
      }
      try {
        await Future.wait(ops);
      } catch (_) {
        ref
            .read(currentUserProvider.notifier)
            .removeIdFromDisliked(prevState.id);
        if (wasLiked) {
          ref.read(currentUserProvider.notifier).addIdToLiked(prevState.id);
        }
        state = AsyncData(prevState);
      }
    }
    _isLiking = false;
  }
}
