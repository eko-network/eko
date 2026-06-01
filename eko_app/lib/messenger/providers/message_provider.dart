import 'package:drift/drift.dart';
import 'package:ecp/ecp.dart';
import 'package:eko_app/database/database.dart';
import 'package:eko_app/database/mappers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part '../../generated/messenger/providers/message_provider.g.dart';

@riverpod
Stream<List<StoredMessage>> message(Ref ref, Uint8List groupId) {
  final query = db.select(db.storedMessages)
    ..where((t) => t.groupId.equals(groupId))
    ..orderBy([(u) => OrderingTerm.asc(u.receivedAt)]);
  return query.watch().map((list) => list.map((v) => v.toMessage()).toList());
}
