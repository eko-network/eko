import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eko_app/providers/pool_providers.dart';
import 'package:eko_app/providers/following_feed_provider.dart';
import 'package:eko_app/providers/new_feed_provider.dart';
import 'package:eko_app/providers/popular_feed_provider.dart';
import 'package:eko_app/providers/profile_post_list_provider.dart';
import 'package:eko_app/types/post.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
// Necessary for code-generation to work
part '../generated/providers/post_provider.g.dart';

@riverpod
class Post extends _$Post {
  Timer? _disposeTimer;
  bool _isLiking = false;
  bool _isVoting = false;
  @override
  FutureOr<PostModel> build(int id) {
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

  Future<PostModel> _fetchPostModel(int id) async {
    final rows = await supabase.rpc('get_post_by_id', params: {'p_id': id});
    final list = rows as List<dynamic>?;
    if (list == null || list.isEmpty) {
      throw Exception('Failed to load');
    }
    return PostModel.fromJson(Map<String, dynamic>.from(list.first as Map));
  }

  Future<void> _changePostLike(
    int id, {
    required bool isLiking,
    required bool isDislike,
  }) async {
    await supabase.rpc(
      'change_post_likes',
      params: {'p_id': id, 'p_is_liking': isLiking, 'p_is_dislike': isDislike},
    );
  }

  Future<void> likePostToggle() async {
    final prevState = await future;
    if (_isLiking) return;
    _isLiking = true;
    if (prevState.isLiked) {
      state = AsyncData(
        prevState.copyWith(isLiked: false, likes: prevState.likes - 1),
      );
      try {
        await _changePostLike(prevState.id, isLiking: false, isDislike: false);
      } catch (e) {
        debugPrint('likePostToggle unlike error: $e');
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
        await _changePostLike(prevState.id, isLiking: true, isDislike: false);
      } catch (e) {
        debugPrint('likePostToggle like error: $e');
        state = AsyncData(prevState);
      }
    }
    _isLiking = false;
  }

  Future<void> dislikePostToggle() async {
    final prevState = await future;
    if (_isLiking) return;
    _isLiking = true;
    if (prevState.isDisliked) {
      state = AsyncData(
        prevState.copyWith(isDisliked: false, dislikes: prevState.dislikes - 1),
      );
      try {
        await _changePostLike(prevState.id, isLiking: false, isDislike: true);
      } catch (e) {
        debugPrint('dislikePostToggle undislike error: $e');
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
        await _changePostLike(prevState.id, isLiking: true, isDislike: true);
      } catch (e) {
        debugPrint('dislikePostToggle dislike error: $e');
        state = AsyncData(prevState);
      }
    }
    _isLiking = false;
  }

  Future<void> addPollVote({required int optionId}) async {
    final prevState = await future;
    if (_isVoting || prevState.vote != null) {
      return;
    }
    _isVoting = true;

    final updatedPoll = (prevState.poll ?? [])
        .map(
          (item) => item.optionId == optionId
              ? item.copyWith(voteCount: item.voteCount + 1)
              : item,
        )
        .toList();
    final optimisticState = prevState.copyWith(
      vote: optionId,
      poll: updatedPoll,
    );
    state = AsyncData(optimisticState);

    try {
      await supabase.rpc(
        'poll_vote',
        params: {'p_post_id': prevState.id, 'p_option_id': optionId},
      );
    } catch (_) {
      state = AsyncData(prevState);
    }

    _isVoting = false;
  }

  Future<void> removePollVote() async {
    final prevState = await future;
    if (_isVoting || prevState.vote == null) {
      return;
    }
    _isVoting = true;
    final currentVote = prevState.vote!;

    final updatedPoll = (prevState.poll ?? [])
        .map(
          (item) => item.optionId == currentVote
              ? item.copyWith(
                  voteCount: (item.voteCount > 0 ? item.voteCount - 1 : 0),
                )
              : item,
        )
        .toList();
    final optimisticState = prevState.copyWith(vote: null, poll: updatedPoll);
    state = AsyncData(optimisticState);

    try {
      await supabase.rpc(
        'remove_poll_vote',
        params: {'p_post_id': prevState.id},
      );
    } catch (_) {
      state = AsyncData(prevState);
    }

    _isVoting = false;
  }

  Future<void> deletePost() async {
    final currentPost = await future;
    final postId = currentPost.id;

    try {
      await supabase.from('posts').delete().eq('id', postId);
      ref.read(followingFeedProvider.notifier).removePost(postId);
      ref.read(newFeedProvider.notifier).removePost(postId);
      ref.read(popularFeedProvider.notifier).removePost(postId);
      ref.read(profilePostListProvider.notifier).removePost(postId);
    } catch (e) {
      rethrow;
    }
  }
}
