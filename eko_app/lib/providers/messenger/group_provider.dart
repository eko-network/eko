import 'package:ecp/core/types/mls_group_record.dart';
import 'package:eko_app/database/database.dart';
import 'package:eko_app/database/mappers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part '../../generated/providers/messenger/group_provider.g.dart';

@riverpod
Stream<List<MlsGroupRecord>> group(Ref ref) {
  final query = db.select(db.mlsGroups)..where((t) => t.isActive.equals(true));
  return query.watch().map((list) => list.map((gr) => gr.toRecord()).toList());
}
