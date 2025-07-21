import 'dart:async';

import 'package:flutter/foundation.dart' show protected;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/types/comment.dart';
import 'package:untitled_app/types/likeable.dart';
import 'package:untitled_app/utilities/like_state.dart';
import 'package:untitled_app/utilities/supabase_ref.dart';
part '../generated/providers/comment_provider.g.dart';

@riverpod
class Comment extends _$Comment with Likeable {
  Timer? _disposeTimer;
  @protected
  @override
  int get contentId => state.valueOrNull?.id ?? 0;

  @protected
  @override
  String get rpcName => 'change_comment_likes';

  @protected
  @override
  int get likes => state.valueOrNull?.likes ?? 0;

  @protected
  @override
  int get dislikes => state.valueOrNull?.dislikes ?? 0;

  @protected
  @override
  LikeState get likeState => state.valueOrNull?.likeState ?? LikeState.none;

  @override
  @protected
  void copyForLikeable(
      {required LikeState likeState, int? likes, int? dislikes}) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        likeState: likeState,
        likes: likes ?? current.likes,
        dislikes: dislikes ?? current.dislikes,
      ),
    );
  }

  @override
  FutureOr<CommentModel> build(int id) {
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
    final cacheValue = ref.read(commentPoolProvider).getItem(id);
    if (cacheValue != null) {
      return cacheValue;
    }

    return _fetchCommentModel(id);
  }

  Future<CommentModel> _fetchCommentModel(int id) async {
    final List response =
        await supabase.rpc('get_comment_by_id', params: {'p_id': id});
    return CommentModel.fromJson(response.first);
  }

  // Future<void> _addLikeToDb(String id) async {
  //   final firestore = FirebaseFirestore.instance;
  //   final uid = ref.read(currentUserProvider).uid;
  //   final comment = await future;
  //   final postId = comment.postId;
  //
  //   await Future.wait([
  //     firestore.collection('users').doc(uid).update({
  //       'profileData.likedPosts': FieldValue.arrayUnion([id])
  //     }),
  //     firestore
  //         .collection('posts')
  //         .doc(postId)
  //         .collection('comments')
  //         .doc(id)
  //         .update({'likes': FieldValue.increment(1)})
  //   ]);
  // }
  //
  // Future<void> _removeLikeFromDb(String commentId) async {
  //   final firestore = FirebaseFirestore.instance;
  //   final uid = ref.read(currentUserProvider).uid;
  //   final comment = await future;
  //   final postId = comment.postId;
  //
  //   await Future.wait([
  //     firestore.collection('users').doc(uid).update({
  //       'profileData.likedPosts': FieldValue.arrayRemove([commentId])
  //     }),
  //     firestore
  //         .collection('posts')
  //         .doc(postId)
  //         .collection('comments')
  //         .doc(commentId)
  //         .update({'likes': FieldValue.increment(-1)}),
  //   ]);
  // }
  //
  // Future<void> _addDislikeToDb(String commentId) async {
  //   final firestore = FirebaseFirestore.instance;
  //   final uid = ref.read(currentUserProvider).uid;
  //   final comment = await future;
  //   final postId = comment.postId;
  //
  //   await Future.wait([
  //     firestore.collection('users').doc(uid).update({
  //       'profileData.dislikedPosts': FieldValue.arrayUnion([commentId])
  //     }),
  //     firestore
  //         .collection('posts')
  //         .doc(postId)
  //         .collection('comments')
  //         .doc(commentId)
  //         .update({'dislikes': FieldValue.increment(1)})
  //   ]);
  // }
  //
  // Future<void> _removeDisikeFromDb(String commentId) async {
  //   final firestore = FirebaseFirestore.instance;
  //   final uid = ref.read(currentUserProvider).uid;
  //   final comment = await future;
  //   final postId = comment.postId;
  //
  //   await Future.wait([
  //     firestore.collection('users').doc(uid).update({
  //       'profileData.dislikedPosts': FieldValue.arrayRemove([commentId])
  //     }),
  //     firestore
  //         .collection('posts')
  //         .doc(postId)
  //         .collection('comments')
  //         .doc(commentId)
  //         .update({'dislikes': FieldValue.increment(-1)}),
  //   ]);
  // }
}
