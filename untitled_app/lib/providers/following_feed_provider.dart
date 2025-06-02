import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/types/post.dart';
import '../utilities/constants.dart' as c;
part '../generated/providers/following_feed_provider.g.dart';

class _Chunk {
  final List<String> uids;
  PostModel newestUnshownPost;
  _Chunk({
    required this.uids,
    required this.newestUnshownPost,
  });
}

@riverpod
class FollowingFeed extends _$FollowingFeed {
  final List<_Chunk> _feedChunks = [];
  final Set<String> _set = {};
  @override
  (List<String>, bool) build() {
    return ([], false);
  }

  Future<void> getter() async {
    final baseQuery = FirebaseFirestore.instance
        .collection('posts')
        .where('tags', arrayContains: 'public')
        .orderBy('time', descending: true)
        .limit(1);
    final List<PostModel> gottenPosts = [];
    if (_feedChunks.isEmpty) {
      final List<String> following = [
        ref.read(currentUserProvider).user.uid,
        ...ref.read(currentUserProvider).user.following
      ];
      final slicedFollowing = following.slices(30).toList();
      final initResults = await Future.wait(slicedFollowing.map((slice) async {
        return (await baseQuery.where('author', whereIn: slice).get()).docs;
      }));
      final List<Future<_Chunk>> asyncChunks = [];
      for (int i = 0; i < slicedFollowing.length; i++) {
        if (initResults[i].isNotEmpty) {
          asyncChunks.add(() async {
            return _Chunk(
              uids: slicedFollowing[i],
              newestUnshownPost:
                  await PostModel.fromFireStoreDoc(initResults[i].first),
            );
          }());
        }
      }
      if (asyncChunks.isEmpty) {
        state = ([], true);
        return;
      }
      _feedChunks.addAll(await Future.wait(asyncChunks));
      _feedChunks.sort((a, b) => b.newestUnshownPost.createdAt
          .compareTo(a.newestUnshownPost.createdAt));
      gottenPosts.add(_feedChunks.first.newestUnshownPost);
    }
    while (gottenPosts.length < c.postsOnRefresh) {
      final snapshot = await baseQuery
          .where('author', whereIn: _feedChunks.first.uids)
          .startAfter([_feedChunks.first.newestUnshownPost.createdAt]).get();
      if (snapshot.docs.isNotEmpty) {
        _feedChunks.first.newestUnshownPost =
            await PostModel.fromFireStoreDoc(snapshot.docs.first);
        _feedChunks.sort(
          (a, b) => b.newestUnshownPost.createdAt
              .compareTo(a.newestUnshownPost.createdAt),
        );
        gottenPosts.add(_feedChunks.first.newestUnshownPost);
      } else {
        _feedChunks.removeAt(0);
        if (_feedChunks.isEmpty) {
          ref.read(postPoolProvider).putAll(gottenPosts);
          final newList = [...state.$1];
          for (final post in gottenPosts) {
            if (_set.add(post.id)) {
              newList.add(post.id);
            }
          }
          state = (newList, true);
        }
      }
    }
    ref.read(postPoolProvider).putAll(gottenPosts);
    final newList = [...state.$1];
    for (final post in gottenPosts) {
      if (_set.add(post.id)) {
        newList.add(post.id);
      }
    }
    state = (newList, false);
  }

  void insertAtIndex(int index, PostModel post) {
    if (_feedChunks.isNotEmpty) {
      if (_set.add(post.id)) {
        final newList = [...state.$1];
        newList.insert(index, post.id);
        state = (newList, state.$2);
      }
    }
  }

  Future<void> refresh() async {
    _set.clear();
    _feedChunks.clear();
    state = ([], false);
    await getter();
  }
}
