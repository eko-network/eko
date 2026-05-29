import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/pool_providers.dart';
import 'package:eko_app/types/comment.dart';
import 'package:eko_app/types/post.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<(List<MapEntry<int, String>>, bool)> profilePageGetter(
  List<MapEntry<int, String>> list,
  WidgetRef ref,
) async {
  final uid = ref.read(currentUserProvider).user.uid;
  final params = <String, dynamic>{
    'p_limit': c.postsOnRefresh,
    'p_user_uid': uid,
  };
  if (list.isNotEmpty) {
    params['p_last_time'] = list.last.value;
    params['p_last_id'] = list.last.key;
  }
  final rows = await supabase.rpc('paginated_user_posts', params: params);
  final rowList = rows as List<dynamic>? ?? const [];
  final postList = rowList
      .map((row) => PostModel.fromJson(Map<String, dynamic>.from(row as Map)))
      .toList();
  ref.read(postPoolProvider).putAll(postList);
  final retList = postList
      .map((item) => MapEntry(item.id, item.createdAt))
      .toList();
  return (retList, retList.length < c.postsOnRefresh);
}

Future<(List<MapEntry<int, String>>, bool)> otherProfilePageGetter(
  List<MapEntry<int, String>> list,
  WidgetRef ref,
  String uid,
) async {
  final params = <String, dynamic>{
    'p_limit': c.postsOnRefresh,
    'p_user_uid': uid,
  };
  if (list.isNotEmpty) {
    params['p_last_time'] = list.last.value;
    params['p_last_id'] = list.last.key;
  }
  final rows = await supabase.rpc('paginated_user_posts', params: params);
  final rowList = rows as List<dynamic>? ?? const [];
  final postList = rowList
      .map((row) => PostModel.fromJson(Map<String, dynamic>.from(row as Map)))
      .where((p) => p.tags.contains('public'))
      .toList();
  ref.read(postPoolProvider).putAll(postList);
  final retList = postList
      .map((item) => MapEntry(item.id, item.createdAt))
      .toList();
  return (retList, retList.length < c.postsOnRefresh);
}

Future<List<CommentModel>> getCommentsForPost(
  int postId, {
  String? lastTime,
  int? lastId,
}) async {
  final params = <String, dynamic>{
    'p_limit': c.postsOnRefresh,
    'p_parent_post_id': postId,
  };
  if (lastTime != null && lastId != null) {
    params['p_last_time'] = lastTime;
    params['p_last_id'] = lastId;
  }
  final rows = await supabase.rpc('paginated_comments', params: params);
  final list = rows as List<dynamic>? ?? const [];
  return list
      .map(
        (row) => CommentModel.fromJson(Map<String, dynamic>.from(row as Map)),
      )
      .toList();
}
