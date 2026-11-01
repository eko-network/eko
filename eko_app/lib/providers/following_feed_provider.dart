import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eko_app/providers/pool_providers.dart';
import 'package:eko_app/types/post.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/utilities/supabase_ref.dart';
part '../generated/providers/following_feed_provider.g.dart';

@riverpod
class FollowingFeed extends _$FollowingFeed {
  final List<MapEntry<int, String>> _cursors = [];
  final Set<int> _set = {};
  @override
  (List<int>, bool) build() {
    return ([], false);
  }

  Future<void> getter() async {
    final params = <String, dynamic>{'p_limit': c.postsOnRefresh};
    if (_cursors.isNotEmpty) {
      final last = _cursors.last;
      params['p_last_time'] = last.value;
      params['p_last_id'] = last.key;
    }
    final rows = await supabase.rpc(
      'paginated_following_posts',
      params: params,
    );
    final list = rows as List<dynamic>? ?? const [];
    final postList = list
        .map((row) => PostModel.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
    ref.read(postPoolProvider).putAll(postList);

    final newList = [...state.$1];
    for (final post in postList) {
      if (_set.add(post.id)) {
        newList.add(post.id);
        _cursors.add(MapEntry(post.id, post.createdAt));
      }
    }
    state = (newList, postList.length < c.postsOnRefresh);
  }

  void insertAtIndex(int index, PostModel post) {
    if (_set.add(post.id)) {
      final newList = [...state.$1];
      newList.insert(index, post.id);
      _cursors.add(MapEntry(post.id, post.createdAt));
      state = (newList, state.$2);
    }
  }

  void removePost(int postId) {
    final newList = [...state.$1];
    final removed = newList.remove(postId);
    if (removed) {
      _set.remove(postId);
      _cursors.removeWhere((e) => e.key == postId);
      state = (newList, state.$2);
    }
  }

  Future<void> refresh() async {
    _set.clear();
    _cursors.clear();
    state = ([], false);
    await getter();
  }
}
