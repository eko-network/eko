import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eko_app/providers/pool_providers.dart';
import 'package:eko_app/types/comment.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
part '../generated/providers/comment_provider.g.dart';

@riverpod
class Comment extends _$Comment {
  Timer? _disposeTimer;
  bool _isLiking = false;

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
    final rows = await supabase.rpc('get_comment_by_id', params: {'p_id': id});
    final list = rows as List<dynamic>? ?? const [];
    final comments = list
        .map(
          (row) => CommentModel.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
    if (comments.isEmpty) {
      throw Exception('Failed to load');
    }
    return comments.first;
  }

  Future<void> _changeCommentLike(
    int id, {
    required bool isLiking,
    required bool isDislike,
  }) async {
    await supabase.rpc(
      'change_comment_likes',
      params: {'p_id': id, 'p_is_liking': isLiking, 'p_is_dislike': isDislike},
    );
  }

  Future<void> likeCommentToggle() async {
    final prevState = await future;
    if (_isLiking) return;
    _isLiking = true;
    if (prevState.isLiked) {
      state = AsyncData(
        prevState.copyWith(isLiked: false, likes: prevState.likes - 1),
      );
      try {
        await _changeCommentLike(
          prevState.id,
          isLiking: false,
          isDislike: false,
        );
      } catch (e) {
        debugPrint('likeCommentToggle unlike error: $e');
        state = AsyncData(prevState);
      }
    } else {
      if (prevState.isDisliked) {
        state = AsyncData(
          prevState.copyWith(
            isLiked: true,
            isDisliked: false,
            likes: prevState.likes + 1,
            dislikes: prevState.dislikes - 1,
          ),
        );
      } else {
        state = AsyncData(
          prevState.copyWith(isLiked: true, likes: prevState.likes + 1),
        );
      }
      try {
        await _changeCommentLike(
          prevState.id,
          isLiking: true,
          isDislike: false,
        );
      } catch (e) {
        debugPrint('likeCommentToggle like error: $e');
        state = AsyncData(prevState);
      }
    }
    _isLiking = false;
  }

  Future<void> dislikeCommentToggle() async {
    final prevState = await future;
    if (_isLiking) return;
    _isLiking = true;
    if (prevState.isDisliked) {
      state = AsyncData(
        prevState.copyWith(isDisliked: false, dislikes: prevState.dislikes - 1),
      );
      try {
        await _changeCommentLike(
          prevState.id,
          isLiking: false,
          isDislike: true,
        );
      } catch (e) {
        debugPrint('dislikeCommentToggle undislike error: $e');
        state = AsyncData(prevState);
      }
    } else {
      if (prevState.isLiked) {
        state = AsyncData(
          prevState.copyWith(
            isDisliked: true,
            isLiked: false,
            dislikes: prevState.dislikes + 1,
            likes: prevState.likes - 1,
          ),
        );
      } else {
        state = AsyncData(
          prevState.copyWith(
            isDisliked: true,
            dislikes: prevState.dislikes + 1,
          ),
        );
      }
      try {
        await _changeCommentLike(prevState.id, isLiking: true, isDislike: true);
      } catch (e) {
        debugPrint('dislikeCommentToggle dislike error: $e');
        state = AsyncData(prevState);
      }
    }
    _isLiking = false;
  }

  Future<void> deleteComment() async {
    final currentComment = await future;
    await supabase.from('comments').delete().eq('id', currentComment.id);
    ref.invalidateSelf();
  }
}
