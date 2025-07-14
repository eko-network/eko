import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/utilities/supabase_ref.dart';
import '../types/comment.dart';
import '../utilities/constants.dart' as c;
part '../generated/providers/comment_list_provider.g.dart';

@riverpod
class CommentList extends _$CommentList {
  (String, int)? _last;
  @override
  (List<int>, bool) build(int postId) {
    return ([], false);
  }

  Future<void> getter(int postId) async {
    final List<dynamic> request =
        await supabase.rpc('paginated_comments', params: {
      'p_limit': c.postsOnRefresh,
      'p_parent_post_id': postId,
      'p_last_time': _last?.$1,
      'p_last_id': _last?.$2
    });

    final commentList = request.map((data) {
      final com = CommentModel.fromJson(data);
      return com;
    });

    if (commentList.isNotEmpty) {
      final lastPost = commentList.last;
      _last = (lastPost.createdAt, lastPost.id);
    }

    ref.read(commentPoolProvider).putAll(commentList);
    final newList = [...state.$1];
    for (final comment in commentList) {
      newList.add(comment.id);
    }
    state = (newList, commentList.length < c.postsOnRefresh);
  }

  Future<void> refresh() async {
    _last = null;
    state = ([], false);
    await getter(postId);
  }

  // void insertAtIndex(int index, CommentModel comment) {
  //   final newList = [...state.$1];
  //   newList.insert(index, comment.id);
  //   _timestamps.add(comment.createdAt);
  //   state = (newList, state.$2);
  // }
  //
  // void addToBack(CommentModel comment) {
  //   final currentLength = state.$1.length;
  //   insertAtIndex(currentLength, comment);
  // }
}
