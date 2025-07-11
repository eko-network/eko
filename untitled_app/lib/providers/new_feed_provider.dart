import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/types/post.dart';
import 'package:untitled_app/utilities/supabase_ref.dart';
import '../utilities/constants.dart' as c;
part '../generated/providers/new_feed_provider.g.dart';

@riverpod
class NewFeed extends _$NewFeed {
  final Set<int> _set = {};
  (String, int)? _last;

  @override
  (List<int>, bool) build() {
    return ([], false);
  }

  Future<void> getter() async {
    final List<dynamic> request = await supabase.rpc('paginated_new_posts',
        params: {
          'p_limit': c.postsOnRefresh,
          'p_last_time': _last?.$1,
          'p_last_id': _last?.$2
        });

    final postList = request.map((data) {
      final post = PostModel.fromJson(data);
      return post;
    });

    if (postList.isNotEmpty) {
      final lastPost = postList.last;
      _last = (lastPost.createdAt, lastPost.id);
    }

    ref.read(postPoolProvider).putAll(postList);
    final newList = [...state.$1];
    for (final post in postList) {
      if (_set.add(post.id)) {
        newList.add(post.id);
      }
    }
    state = (newList, postList.length < c.postsOnRefresh);
  }

  Future<void> refresh() async {
    _set.clear();
    _last = null;
    state = ([], false);
    await getter();
  }

  // void insertAtIndex(int index, PostModel post) {
  //   if (_set.add(post.id)) {
  //     final newList = [...state.$1];
  //     newList.insert(index, post.id);
  //     state = (newList, state.$2);
  //   }
  // }
}
