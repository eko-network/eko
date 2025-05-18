import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled_app/providers/comment_pool_provider.dart';
import 'package:untitled_app/providers/post_pool_provider.dart';
import 'package:untitled_app/types/comment.dart';
import '../utilities/constants.dart' as c;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/types/post.dart';

Future<List<PostModel>> getPosts(
  Query<Map<String, dynamic>> query,
) async {
  final postList = await Future.wait(
    await query.get().then(
          (data) => data.docs.map(
            (doc) async {
              return await PostModel.fromFireStoreDoc(doc);
            },
          ),
        ),
  );
  return postList;
}

Future<(List<MapEntry<String, String>>, bool)> profilePageGetter(
    List<MapEntry<String, String>> list, WidgetRef ref) async {
  final uid = ref.read(currentUserProvider).user.uid;
  final baseQuery = FirebaseFirestore.instance
      .collection('posts')
      .where('author', isEqualTo: uid)
      .orderBy('time', descending: true)
      .limit(c.postsOnRefresh);
  final query =
      list.isEmpty ? baseQuery : baseQuery.startAfter([list.last.value]);

  final postList = await getPosts(query);
  ref.read(postPoolProvider).putAll(postList);
  final retList =
      postList.map((item) => MapEntry(item.id, item.createdAt)).toList();
  return (retList, retList.length < c.postsOnRefresh);
}

Future<(List<MapEntry<String, String>>, bool)> otherProfilePageGetter(
    List<MapEntry<String, String>> list, WidgetRef ref, String uid) async {
  final baseQuery = FirebaseFirestore.instance
      .collection('posts')
      .where('tags', arrayContains: 'public')
      .where('author', isEqualTo: uid)
      .orderBy('time', descending: true)
      .limit(c.postsOnRefresh);
  final query =
      list.isEmpty ? baseQuery : baseQuery.startAfter([list.last.value]);
  final postList = await getPosts(query);
  ref.read(postPoolProvider).putAll(postList);
  final retList =
      postList.map((item) => MapEntry(item.id, item.createdAt)).toList();
  return (retList, retList.length < c.postsOnRefresh);
}

Future<(List<MapEntry<String, int>>, bool)> popGetter(
    List<MapEntry<String, int>> list, WidgetRef ref) async {
  final baseQuery = FirebaseFirestore.instance
      .collection('posts')
      .where('tags', arrayContains: 'public')
      .orderBy('likes', descending: true)
      .limit(c.postsOnRefresh);
  final query =
      list.isEmpty ? baseQuery : baseQuery.startAfter([list.last.value]);
  final postList = await getPosts(query);
  ref.read(postPoolProvider).putAll(postList);
  final retList =
      postList.map((item) => MapEntry(item.id, item.likes)).toList();
  return (retList, retList.length < c.postsOnRefresh);
}

Future<List<CommentModel>> getComments(
    Query<Map<String, dynamic>> query) async {
  final commentList = await Future.wait(
    await query.get().then(
          (data) => data.docs.map(
            (doc) async {
              return await CommentModel.fromFireStoreDoc(doc);
            },
          ),
        ),
  );
  return commentList;
}

Future<(List<MapEntry<String, String>>, bool)> commentsGetter(
    List<MapEntry<String, String>> list, WidgetRef ref, String postId) async {
  final baseQuery = FirebaseFirestore.instance
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .orderBy('time', descending: false)
      .limit(c.postsOnRefresh);
  final query =
      list.isEmpty ? baseQuery : baseQuery.startAfter([list.last.value]);

  final commentList = await getComments(query);
  ref.read(commentPoolProvider).putAll(commentList);
  final retList =
      commentList.map((item) => MapEntry(item.id, item.createdAt)).toList();
  return (retList, retList.length < c.postsOnRefresh);
}
