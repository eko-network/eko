import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/interfaces/post_queries.dart';
import 'package:untitled_app/providers/post_pool_provider.dart';
import '../utilities/constants.dart' as c;
part '../generated/providers/new_feed_provider.g.dart';

@riverpod
class NewFeed extends _$NewFeed {
  final List<String> _timestamps = [];
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
    final postList = await getPosts(
        query);

    ref.read(postPoolProvider).putAll(postList.map((item) => item.key));
    final newList = [...state.$1];
    for (final postMap in postList) {
      newList.add(postMap.key.id);
      _timestamps.add(postMap.value);
    }
    state = (newList, postList.length < c.postsOnRefresh);
  }

  Future<void> refresh() async {
    state = ([], false);
    await getter();
  }
}
