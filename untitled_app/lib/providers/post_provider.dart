import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/interfaces/post.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/types/post.dart';
import 'package:untitled_app/utilities/like_state.dart';
import 'package:untitled_app/utilities/supabase_ref.dart';
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
    final List response =
        await supabase.rpc('get_post_by_id', params: {'p_id': id});
    return PostModel.fromJson(response.first);
  }

  Future<void> likePostToggle() async {
    print('${ref.read(currentUserProvider).uid} ${(await future).id}');
    if (_isLiking) return;
    _isLiking = true;
    final prev = await future;
    if (prev.likeState == LikeState.liked) {
      state = AsyncData(
          prev.copyWith(likeState: LikeState.none, likes: prev.likes - 1));
      await supabase.rpc('change_post_likes', params: {
        'p_id': prev.id,
        'p_is_liking': false,
        'p_is_dislike': false,
      });
    } else {
      if (prev.likeState == LikeState.disliked) {
        state = AsyncData(prev.copyWith(
            likeState: LikeState.liked,
            likes: prev.likes + 1,
            dislikes: prev.dislikes - 1));
      } else {
        state = AsyncData(
            prev.copyWith(likeState: LikeState.liked, likes: prev.likes + 1));
      }
      await supabase.rpc('change_post_likes', params: {
        'p_id': prev.id,
        'p_is_liking': true,
        'p_is_dislike': false,
      });
    }
    _isLiking = false;
  }

  Future<void> dislikePostToggle() async {
    if (_isLiking) return;
    _isLiking = true;
    final prev = await future;
    if (prev.likeState == LikeState.disliked) {
      state = AsyncData(prev.copyWith(
          likeState: LikeState.none, dislikes: prev.dislikes - 1));
      await supabase.rpc('change_post_likes', params: {
        'p_id': prev.id,
        'p_is_liking': false,
        'p_is_dislike': true,
      });
    } else {
      if (prev.likeState == LikeState.liked) {
        state = AsyncData(prev.copyWith(
            likeState: LikeState.disliked,
            likes: prev.likes - 1,
            dislikes: prev.dislikes + 1));
      } else {
        state = AsyncData(prev.copyWith(
            likeState: LikeState.disliked, dislikes: prev.dislikes + 1));
      }
      await supabase.rpc('change_post_likes', params: {
        'p_id': prev.id,
        'p_is_liking': true,
        'p_is_dislike': true,
      });
    }
    _isLiking = false;
  }

  Future<void> _addVoteToDb(String id, int optionIndex) async {
    final firestore = FirebaseFirestore.instance;
    final uid = ref.read(currentUserProvider).uid;
    await Future.wait([
      firestore
          .collection('users')
          .doc(uid)
          .update({'profileData.pollVotes.$id': optionIndex}),
      firestore
          .collection('posts')
          .doc(id)
          .update({'pollVoteCounts.$optionIndex': FieldValue.increment(1)}),
    ]);
  }

  Future<void> _removeVoteFromDb(String id, int currentVote) async {
    final firestore = FirebaseFirestore.instance;
    final uid = ref.read(currentUserProvider).uid;
    await Future.wait([
      firestore
          .collection('users')
          .doc(uid)
          .update({'profileData.pollVotes.$id': FieldValue.delete()}),
      firestore
          .collection('posts')
          .doc(id)
          .update({'pollVoteCounts.$currentVote': FieldValue.increment(-1)}),
    ]);
  }

  Future<void> addPollVote({required int optionIndex}) async {
    // final prevState = await future;
    // if (_isVoting ||
    //     ref.read(currentUserProvider).pollVotes.containsKey(prevState.id)) {
    //   return;
    // }
    // _isVoting = true;

    // ref
    //     .read(currentUserProvider.notifier)
    //     .addPollVote(prevState.id, optionIndex);

    // final updatedPollVoteCounts =
    //     Map<String, int>.from(prevState.pollVoteCounts ?? {});
    // updatedPollVoteCounts[optionIndex.toString()] =
    //     (updatedPollVoteCounts[optionIndex.toString()] ?? 0) + 1;

    // state =
    //     AsyncData(prevState.copyWith(pollVoteCounts: updatedPollVoteCounts));

    // try {
    //   await _addVoteToDb(prevState.id, optionIndex);
    // } catch (_) {
    //   ref.read(currentUserProvider.notifier).removePollVote(prevState.id);
    //   state = AsyncData(prevState);
    // }

    // _isVoting = false;
  }

  Future<void> removePollVote() async {
    // final prevState = await future;
    // if (_isVoting ||
    //     !ref.read(currentUserProvider).pollVotes.containsKey(prevState.id)) {
    //   return;
    // }
    // _isVoting = true;
    // final currentVote = ref.read(currentUserProvider).pollVotes[prevState.id]!;

    // ref.read(currentUserProvider.notifier).removePollVote(prevState.id);

    // final updatedPollVoteCounts =
    //     Map<String, int>.from(prevState.pollVoteCounts!);
    // updatedPollVoteCounts[currentVote.toString()] =
    //     (updatedPollVoteCounts[currentVote.toString()] ?? 1) - 1;

    // state =
    //     AsyncData(prevState.copyWith(pollVoteCounts: updatedPollVoteCounts));

    // try {
    //   await _removeVoteFromDb(prevState.id, currentVote);
    // } catch (_) {
    //   ref.read(currentUserProvider.notifier).removePollVote(prevState.id);
    //   state = AsyncData(prevState);
    // }

    // _isVoting = false;
  }
}
