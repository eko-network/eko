import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/types/post.dart';
import 'package:untitled_app/utilities/supabase_ref.dart';
import '../utilities/constants.dart' as c;
part '../generated/providers/new_feed_provider.g.dart';

@riverpod
class NewFeed extends _$NewFeed {
  int _page = 0;
  final Set<int> _set = {};

  @override
  (List<int>, bool) build() {
    return ([], false);
  }

  Future<void> getter() async {
    final postList = (await supabase.rpc('paginated_new_posts',
            params: {'p_limit': c.postsOnRefresh, 'p_offset': _page++}))
        .map((data) => PostModel.fromJson(data))
        .toList();

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
    _page = 0;
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
