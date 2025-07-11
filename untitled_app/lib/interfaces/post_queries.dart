import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/types/comment.dart';
import 'package:untitled_app/utilities/supabase_ref.dart';
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
  // final uid = ref.read(currentUserProvider).uid;
  // final baseQuery = FirebaseFirestore.instance
  //     .collection('posts')
  //     .where('author', isEqualTo: uid)
  //     .orderBy('time', descending: true)
  //     .limit(c.postsOnRefresh);
  // final query =
  //     list.isEmpty ? baseQuery : baseQuery.startAfter([list.last.value]);
  //
  // final postList = await getPosts(query);
  // ref.read(postPoolProvider).putAll(postList);
  // final retList =
  //     postList.map((item) => MapEntry(item.id, item.createdAt)).toList();
  // return (retList, retList.length < c.postsOnRefresh);
  return ([] as List<MapEntry<String, String>>, true);
}

Future<(List<MapEntry<String, String>>, bool)> otherProfilePageGetter(
    List<MapEntry<String, String>> list, WidgetRef ref, String uid) async {
  // final baseQuery = FirebaseFirestore.instance
  //     .collection('posts')
  //     .where('tags', arrayContains: 'public')
  //     .where('author', isEqualTo: uid)
  //     .orderBy('time', descending: true)
  //     .limit(c.postsOnRefresh);
  // final query =
  //     list.isEmpty ? baseQuery : baseQuery.startAfter([list.last.value]);
  // final postList = await getPosts(query);
  // ref.read(postPoolProvider).putAll(postList);
  // final retList =
  //     postList.map((item) => MapEntry(item.id, item.createdAt)).toList();
  // return (retList, retList.length < c.postsOnRefresh);
  return ([] as List<MapEntry<String, String>>, true);
}

Future<(List<(int, int)>, bool)> popGetter(
    List<(int, int)> list, WidgetRef ref) async {
  final last = list.isNotEmpty ? list.last : null;
  final List<dynamic> response = await supabase.rpc('paginated_popular_posts',
      params: {
        'p_limit': c.postsOnRefresh,
        'p_last_likes': last?.$2,
        'p_last_id': last?.$1
      });
  final postList = response.map((post) => PostModel.fromJson(post));
  ref.read(postPoolProvider).putAll(postList);
  final retList = postList.map((post) => (post.id, post.likes)).toList();
  return (retList, retList.length < c.postsOnRefresh);
}

Future<(List<MapEntry<String, String>>, bool)> getGroupPosts(
    List<MapEntry<String, String>> list, WidgetRef ref, String groupId) async {
  // final baseQuery = FirebaseFirestore.instance
  //     .collection('posts')
  //     .where('tags', arrayContains: groupId)
  //     .orderBy('time', descending: true)
  //     .limit(c.postsOnRefresh);
  // final query =
  //     list.isEmpty ? baseQuery : baseQuery.startAfter([list.last.value]);
  // final postList = await getPosts(query);
  // ref.read(postPoolProvider).putAll(postList);
  // final retList =
  //     postList.map((item) => MapEntry(item.id, item.createdAt)).toList();
  return ([] as List<MapEntry<String, String>>, true);
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
