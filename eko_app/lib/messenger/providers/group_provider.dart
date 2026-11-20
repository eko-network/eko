import 'package:drift/drift.dart';
import 'package:ecp/ecp.dart';
import 'package:eko_app/database/database.dart';
import 'package:eko_app/database/mappers.dart';
import 'package:eko_app/messenger/ecp_helpers.dart';
import 'package:eko_app/providers/ecp_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part '../../generated/messenger/providers/group_provider.g.dart';

/// The active groups, the one with the newest message first.
@riverpod
Stream<List<MlsGroupRecord>> group(Ref ref) {
  // they are the client's state, so only shown once it is ready
  ref.watch(ecpClientProvider);
  final query = db.select(db.mlsGroups)
    ..where((t) => t.isActive.equals(true))
    ..orderBy([(t) => OrderingTerm.desc(t.lastActivityAt)]);
  return query.watch().map((rows) => [for (final row in rows) row.toRecord()]);
}

/// The uids of the members of the group with row id [groupId]. Only their
/// devices change after a group is made, not who is in it.
@riverpod
Future<List<String>> groupMembers(Ref ref, int groupId) async {
  final ecp = ref.watch(ecpClientProvider);
  final group = await ecp.core.storage.groupStore.getGroup(groupId);
  if (group == null) throw StateError('no group with id $groupId');
  final gm = await ecp.groups.getMembers(group);
  return gm.members.map((m) => m.uid()).toList();
}
