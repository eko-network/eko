import 'package:eko_app/database/database.dart';
import 'package:eko_app/database/mappers.dart';
import 'package:eko_app/messenger/ecp_helpers.dart';
import 'package:eko_app/messenger/types/group.dart';
import 'package:eko_app/providers/ecp_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part '../../generated/messenger/providers/group_provider.g.dart';

@riverpod
Stream<List<GroupWithUsers>> group(Ref ref) {
  final ecp = ref.watch(ecpClientProvider);
  final query = db.select(db.mlsGroups)..where((t) => t.isActive.equals(true));
  return query.watch().asyncMap((list) async {
    final l = list.map((gr) => gr.toRecord());
    return await Future.wait(
      l.map((gr) async {
        final gm = await ecp.groups.getMembers(gr);
        return (
          group: gm.group,
          users: gm.members.map((m) => m.uid()).toList(),
        );
      }),
    );
  });
}
