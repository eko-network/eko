import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/pool_providers.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/types/post.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ProfilePostListState = (List<int>, bool);

enum ProfilePostSort { newest, popular }

class ProfilePostListNotifier extends Notifier<ProfilePostListState> {
  final List<MapEntry<int, String>> _newestCursors = [];
  final List<MapEntry<int, int>> _popularCursors = [];
  final Set<int> _set = {};
  ProfilePostSort _sort = ProfilePostSort.newest;

  @override
  ProfilePostListState build() => ([], false);

  Future<void> setSort(ProfilePostSort sort) async {
    if (_sort == sort) {
      return;
    }
    _sort = sort;
    await refresh();
  }

  Future<void> getter() async {
    final params = <String, dynamic>{
      'p_limit': c.postsOnRefresh,
      'p_user_uid': ref.read(currentUserProvider).user.uid,
    };
    final isPopular = _sort == ProfilePostSort.popular;
    if (isPopular && _popularCursors.isNotEmpty) {
      params['p_last_likes'] = _popularCursors.last.value;
      params['p_last_id'] = _popularCursors.last.key;
    } else if (!isPopular && _newestCursors.isNotEmpty) {
      params['p_last_time'] = _newestCursors.last.value;
      params['p_last_id'] = _newestCursors.last.key;
    }
    final rows = await supabase.rpc(
      isPopular ? 'paginated_user_posts_popular' : 'paginated_user_posts',
      params: params,
    );
    final list = rows as List<dynamic>? ?? const [];
    final posts = list
        .map((row) => PostModel.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
    ref.read(postPoolProvider).putAll(posts);

    final newList = [...state.$1];
    for (final post in posts) {
      if (_set.add(post.id)) {
        newList.add(post.id);
        if (isPopular) {
          _popularCursors.add(MapEntry(post.id, post.likes + post.dislikes));
        } else {
          _newestCursors.add(MapEntry(post.id, post.createdAt));
        }
      }
    }
    state = (newList, posts.length < c.postsOnRefresh);
  }

  void _resetPagination() {
    _set.clear();
    _newestCursors.clear();
    _popularCursors.clear();
    state = ([], false);
  }

  Future<void> refresh() async {
    _resetPagination();
    await getter();
  }

  void removePost(int postId) {
    final newList = [...state.$1];
    final removed = newList.remove(postId);
    if (removed) {
      _set.remove(postId);
      _newestCursors.removeWhere((entry) => entry.key == postId);
      _popularCursors.removeWhere((entry) => entry.key == postId);
      state = (newList, state.$2);
    }
  }
}

class OtherProfilePostListNotifier extends Notifier<ProfilePostListState> {
  OtherProfilePostListNotifier(this.uid);

  final String uid;
  final List<MapEntry<int, String>> _newestCursors = [];
  final List<MapEntry<int, int>> _popularCursors = [];
  final Set<int> _set = {};
  ProfilePostSort _sort = ProfilePostSort.newest;

  @override
  ProfilePostListState build() => ([], false);

  Future<void> setSort(ProfilePostSort sort) async {
    if (_sort == sort) {
      return;
    }
    _sort = sort;
    await refresh();
  }

  Future<void> getter() async {
    final params = <String, dynamic>{
      'p_limit': c.postsOnRefresh,
      'p_user_uid': uid,
    };
    final isPopular = _sort == ProfilePostSort.popular;
    if (isPopular && _popularCursors.isNotEmpty) {
      params['p_last_likes'] = _popularCursors.last.value;
      params['p_last_id'] = _popularCursors.last.key;
    } else if (!isPopular && _newestCursors.isNotEmpty) {
      params['p_last_time'] = _newestCursors.last.value;
      params['p_last_id'] = _newestCursors.last.key;
    }
    final rows = await supabase.rpc(
      isPopular ? 'paginated_user_posts_popular' : 'paginated_user_posts',
      params: params,
    );
    final list = rows as List<dynamic>? ?? const [];
    final posts = list
        .map((row) => PostModel.fromJson(Map<String, dynamic>.from(row as Map)))
        .where((post) => post.tags.contains('public'))
        .toList();
    ref.read(postPoolProvider).putAll(posts);

    final newList = [...state.$1];
    for (final post in posts) {
      if (_set.add(post.id)) {
        newList.add(post.id);
        if (isPopular) {
          _popularCursors.add(MapEntry(post.id, post.likes + post.dislikes));
        } else {
          _newestCursors.add(MapEntry(post.id, post.createdAt));
        }
      }
    }
    state = (newList, posts.length < c.postsOnRefresh);
  }

  void _resetPagination() {
    _set.clear();
    _newestCursors.clear();
    _popularCursors.clear();
    state = ([], false);
  }

  Future<void> refresh() async {
    _resetPagination();
    await getter();
  }
}

final profilePostListProvider =
    NotifierProvider<ProfilePostListNotifier, ProfilePostListState>(
  ProfilePostListNotifier.new,
);

final otherProfilePostListProvider = NotifierProvider.family<
    OtherProfilePostListNotifier,
    ProfilePostListState,
    String>((uid) => OtherProfilePostListNotifier(uid));

class _ProfilePostSort extends Notifier<ProfilePostSort> {
  @override
  ProfilePostSort build() => ProfilePostSort.newest;
}

final profilePostSortProvider =
    NotifierProvider<_ProfilePostSort, ProfilePostSort>(_ProfilePostSort.new);

class _OtherProfilePostSort extends Notifier<ProfilePostSort> {
  @override
  ProfilePostSort build() => ProfilePostSort.newest;
}

final otherProfilePostSortProvider =
    NotifierProvider.family<_OtherProfilePostSort, ProfilePostSort, String>(
  (_) => _OtherProfilePostSort(),
);
