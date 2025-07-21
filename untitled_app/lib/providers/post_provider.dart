import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/types/likeable.dart';
import 'package:untitled_app/types/post.dart';
import 'package:untitled_app/utilities/like_state.dart';
import 'package:untitled_app/utilities/supabase_ref.dart';
part '../generated/providers/post_provider.g.dart';

@riverpod
class Post extends _$Post with Likeable {
  Timer? _disposeTimer;
  bool _isVoting = false;

  @protected
  @override
  int get contentId => state.valueOrNull?.id ?? 0;

  @protected
  @override
  String get rpcName => 'change_post_likes';

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
  FutureOr<PostModel> build(int id) {
    // *** This block is for lifecycle management *** //
    // K()ep provider alive
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
