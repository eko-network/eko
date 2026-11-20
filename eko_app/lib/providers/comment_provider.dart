import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eko_app/providers/pool_providers.dart';
import 'package:eko_app/types/comment.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
part '../generated/providers/comment_provider.g.dart';

@Riverpod(keepAlive: true)
class Comment extends _$Comment {
  DateTime? _idleSince;
  bool _isLiking = false;

  @override
  FutureOr<CommentModel> build(int id) {
    // *** This block is for lifecycle management *** //
    // Never disposed: if it were, scrolling back to the comment would show a
    // loader, changing its height and shifting the list. Instead refresh it
    // when it comes back on screen after being idle for a while.
    ref.onCancel(() {
      _idleSince = DateTime.now();
    });
    ref.onResume(() {
      final idleSince = _idleSince;
      _idleSince = null;
      if (idleSince != null &&
          DateTime.now().difference(idleSince) > const Duration(minutes: 3)) {
        // ref can't be used inside life-cycles so refresh after this one
        Future.microtask(() => _refresh(id));
      }
    });
    // ********************************************* //
    // await Future.delayed(Duration(seconds: 100));
    final cacheValue = ref.read(commentPoolProvider).getItem(id);
    if (cacheValue != null) {
      return cacheValue;
    }

    return _fetchCommentModel(id);
  }

  /// Refetches in the background, keeping the current value on screen meanwhile
  Future<void> _refresh(int id) async {
    if (!ref.mounted) return;
    final current = state.value;
    try {
      final fresh = await _fetchCommentModel(id);
      // don't clobber changes made while fetching (e.g. a like)
      if (ref.mounted && identical(state.value, current)) {
        state = AsyncData(fresh);
      }
    } catch (_) {}
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
