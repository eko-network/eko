import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/interfaces/post_queries.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import '../types/comment.dart';
import '../utilities/constants.dart' as c;
part '../generated/providers/comment_list_provider.g.dart';

@riverpod
class CommentList extends _$CommentList {
  final List<String> _timestamps = [];
  @override
  (List<String>, bool) build(String postId) {
    return ([], false);
  }

  Future<void> getter(String postId) async {
    final baseQuery = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('time', descending: false)
        .limit(c.postsOnRefresh);
    final query =
        state.$1.isEmpty ? baseQuery : baseQuery.startAfter([_timestamps.last]);

    final commentList = await getComments(query);
    ref.read(commentPoolProvider).putAll(commentList);

    final newList = [...state.$1];
    for (final comment in commentList) {
      newList.add(comment.id);
      _timestamps.add(comment.createdAt);
    }
    state = (newList, commentList.length < c.postsOnRefresh);
  }

  Future<void> refresh() async {
    _timestamps.clear();
    state = ([], false);
    await getter(postId);
  }

  void insertAtIndex(int index, CommentModel comment) {
    final newList = [...state.$1];
    newList.insert(index, comment.id);
    _timestamps.add(comment.createdAt);
    state = (newList, state.$2);
  }

  void addToBack(CommentModel comment) {
    final currentLength = state.$1.length;
    insertAtIndex(currentLength, comment);
  }
}
