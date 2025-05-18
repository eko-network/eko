import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled_app/providers/post_pool_provider.dart';
import '../utilities/constants.dart' as c;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/types/post.dart';

Future<List<MapEntry<PostModel, String>>> getPosts(
  Query<Map<String, dynamic>> query,
) async {
  final postList = await Future.wait(
    await query.get().then(
          (data) => data.docs.map(
            (doc) async {
              return MapEntry(
                  await PostModel.fromFireStoreDoc(doc), doc.data()['time'] as String);
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
  final onlyPosts = postList.map((item) => item.key).toList();
  ref.read(postPoolProvider).putAll(onlyPosts);
  final retList =
      postList.map((item) => MapEntry(item.key.id, item.value)).toList();
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
  final onlyPosts = postList.map((item) => item.key).toList();
  ref.read(postPoolProvider).putAll(onlyPosts);
  final retList =
      postList.map((item) => MapEntry(item.key.id, item.value)).toList();
  return (retList, retList.length < c.postsOnRefresh);
}

Future<(List<MapEntry<String, String>>, bool)> newPageGetter(
    List<MapEntry<String, String>> list, WidgetRef ref) async {
  final baseQuery = FirebaseFirestore.instance
      .collection('posts')
      .where('tags', arrayContains: 'public')
      .orderBy('time', descending: true)
      .limit(c.postsOnRefresh);
  final query =
      list.isEmpty ? baseQuery : baseQuery.startAfter([list.last.value]);
  final postList = await getPosts(query);
  final onlyPosts = postList.map((item) => item.key).toList();
  ref.read(postPoolProvider).putAll(onlyPosts);
  final retList =
      postList.map((item) => MapEntry(item.key.id, item.value)).toList();
  return (retList, retList.length < c.postsOnRefresh);
}

Future<(List<MapEntry<String, String>>, bool)> followingGetter(
    List<MapEntry<String, String>> list, WidgetRef ref) async {
  final baseQuery = FirebaseFirestore.instance
      .collection('posts')
      .orderBy('time', descending: true)
      .limit(c.postsOnRefresh);
  final query =
      list.isEmpty ? baseQuery : baseQuery.startAfter([list.last.value]);
  final postList = await getPosts(query);
  final onlyPosts = postList.map((item) => item.key).toList();
  ref.read(postPoolProvider).putAll(onlyPosts);
  final retList =
      postList.map((item) => MapEntry(item.key.id, item.value)).toList();
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
  final onlyPosts = postList.map((item) => item.key).toList();
  ref.read(postPoolProvider).putAll(onlyPosts);
  final retList =
      postList.map((item) => MapEntry(item.key.id, item.key.likes)).toList();
  return (retList, retList.length < c.postsOnRefresh);
}
