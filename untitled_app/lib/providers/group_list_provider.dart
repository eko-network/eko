import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/types/group.dart';
import 'package:untitled_app/utilities/supabase_ref.dart';
import '../utilities/constants.dart' as c;
part '../generated/providers/group_list_provider.g.dart';

@riverpod
class GroupList extends _$GroupList {
  final Set<int> _set = {};
  (String, int)? _last;
  Timer? _disposeTimer;
  @override
  (List<int>, bool) build() {
    // keeping this alive for a little make the compose page feel better
    // *** This block is for lifecycle management *** //
    // Keep provider alive
    final link = ref.keepAlive();
    ref.onCancel(() {
      // Start a 3-minute countdown when the last listener goes away
      _disposeTimer = Timer(const Duration(minutes: 1), () {
        link.close();
      });
    });
    ref.onResume(() {
      // Cancel the timer if a listener starts again
      _disposeTimer?.cancel();
    });
    ref.onDispose(() {
      // ckean up if the provider is somehow disposed
      _disposeTimer?.cancel();
    });
    // ********************************************* //
    return ([], false);
  }

  Future<void> getter() async {
    final List<dynamic> request = await supabase.rpc('paginated_chambers',
        params: {
          'p_limit': c.postsOnRefresh,
          'p_last_time': _last?.$1,
          'p_last_id': _last?.$2
        });

    final groupList = request.map((data) {
      final group = GroupModel.fromJson(data);
      return group;
    });

    if (groupList.isNotEmpty) {
      final lastGroup = groupList.last;
      _last = (lastGroup.lastActivity, lastGroup.id);
    }

    ref.read(groupPoolProvider).putAll(groupList);
    final newList = [...state.$1];
    for (final group in groupList) {
      if (_set.add(group.id)) {
        newList.add(group.id);
      }
    }
    state = (newList, groupList.length < c.postsOnRefresh);
  }

  Future<void> refresh() async {
    _set.clear();
    _last = null;
    state = ([], false);
    await getter();
  }

  void removeGroupById(int id) async {
    final newList = [...state.$1];
    newList.remove(id);
    _set.remove(id);
    state = (newList, state.$2);
  }

  // void insertAtIndex(int index, GroupModel group) {
  //   final newList = [...state.$1];
  //   newList.insert(index, group.id);
  //   _timestamps.insert(index, group.createdOn);
  //   state = (newList, state.$2);
  // }
}
