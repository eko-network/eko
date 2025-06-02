import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/interfaces/post_queries.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/types/post.dart';
import '../utilities/constants.dart' as c;
part '../generated/providers/new_feed_provider.g.dart';

@riverpod
class NewFeed extends _$NewFeed {
  final List<String> _timestamps = [];
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
        .limit(c.postsOnRefresh);
    final query =
        state.$1.isEmpty ? baseQuery : baseQuery.startAfter([_timestamps.last]);
    final postList = await getPosts(query);

    ref.read(postPoolProvider).putAll(postList);
    final newList = [...state.$1];
    for (final post in postList) {
      if (_set.add(post.id)) {
        newList.add(post.id);
        _timestamps.add(post.createdAt);
      }
    }
    state = (newList, postList.length < c.postsOnRefresh);
  }

  Future<void> refresh() async {
    _set.clear();
    _timestamps.clear();
    state = ([], false);
    await getter();
  }

  void insertAtIndex(int index, PostModel post) {
    if (_set.add(post.id)) {
      final newList = [...state.$1];
      newList.insert(index, post.id);
      _timestamps.add(post.createdAt);
      state = (newList, state.$2);
    }
  }
}
