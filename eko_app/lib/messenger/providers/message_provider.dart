import 'dart:async';

import 'package:drift/drift.dart';
import 'package:ecp/ecp.dart';
import 'package:eko_app/database/database.dart';
import 'package:eko_app/database/mappers.dart';
import 'package:eko_app/database/storage.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/ecp_provider.dart';
import 'package:eko_app/utilities/platform.dart' as platform;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part '../../generated/messenger/providers/message_provider.g.dart';

/// The MLS group ID of the group with row id [id], which it keeps for good.
///
/// The providers of a group are by row id, as the bytes of the same group
/// read again are not equal to the ones read before.
@riverpod
Future<Uint8List> groupIdBytes(Ref ref, int id) async {
  final row = await (db.select(
    db.mlsGroups,
  )..where((t) => t.id.equals(id))).getSingle();
  return row.groupIdBytes;
}

@riverpod
Stream<List<StoredMessage>> message(Ref ref, int id) async* {
  final groupId = await ref.watch(groupIdBytesProvider(id).future);
  final messages = db.storedMessages;
  final attachments = db.messageAttachments;
  final query =
      db.select(messages).join([
          leftOuterJoin(
            attachments,
            attachments.messageId.equalsExp(messages.serverActivityId),
          ),
        ])
        ..where(messages.groupId.equals(groupId))
        ..orderBy([
          OrderingTerm.asc(messages.receivedAt),
          OrderingTerm.asc(attachments.position),
        ]);
  yield* query.watch().map((rows) {
    // insertion ordered, so messages keep the query's order
    final grouped = <Uri, (StoredMessageRow, List<ActivityPubObject>)>{};
    for (final row in rows) {
      final message = row.readTable(messages);
      final entry = grouped.putIfAbsent(
        message.serverActivityId,
        () => (message, []),
      );
      final object = row.readTableOrNull(attachments)?.object;
      if (object == null) continue;
      try {
        entry.$2.add(ActivityPubObject.fromJson(object));
      } catch (e) {
        debugPrint('[message] skipping unreadable attachment: $e');
      }
    }
    final result = grouped.values
        .map((entry) => entry.$1.toMessage(entry.$2))
        .toList();
    unawaited(_sendPendingDeliveryAcks(ref, result));
    return result;
  });
}

Future<void> _sendPendingDeliveryAcks(
  Ref ref,
  List<StoredMessage> messages,
) async {
  final client = ref.read(ecpClientProvider);
  final me = client.core.identity.id;

  for (final message in messages) {
    if (message.delivered || message.senderId == me) continue;

    final deliveredActivity = WireActivity.wireDelivered(
      actor: me,
      to: [message.senderId],
      object: message.serverActivityId,
    );
    try {
      await client.messages.activitySender.sendActivity(deliveredActivity);
    } catch (e) {
      debugPrint('sendPendingDeliveryAcks failed: $e');
    }
    // if it fails, for whatever reason, just mark it delivered anyways so it doesnt retry
    await client.core.storage.messageStore.markMessageDelivered(
      message.serverActivityId,
    );
  }
}

/// The reactions in a group, by the message they react to, oldest first.
@riverpod
Stream<Map<InternalId, List<StoredReaction>>> reactions(
  Ref ref,
  int id,
) async* {
  final groupId = await ref.watch(groupIdBytesProvider(id).future);
  final query = db.select(db.messageReactions)
    ..where((t) => t.groupId.equals(groupId))
    ..orderBy([(t) => OrderingTerm.asc(t.receivedAt)]);
  yield* query.watch().map((rows) {
    final byMessage = <InternalId, List<StoredReaction>>{};
    for (final row in rows) {
      byMessage.putIfAbsent(row.messageId, () => []).add(row.toReaction());
    }
    return byMessage;
  });
}

/// How far each member read a group, by reader.
@riverpod
Stream<Map<Uri, ReadCursor>> readCursors(Ref ref, int id) async* {
  final groupId = await ref.watch(groupIdBytesProvider(id).future);
  final query = db.select(db.readCursors)
    ..where((t) => t.groupId.equals(groupId));
  yield* query.watch().map(
    (rows) => {for (final row in rows) row.reader: row.toCursor()},
  );
}

/// How many messages of others in a group we have not read.
@riverpod
Stream<int> unreadCount(Ref ref, int id) async* {
  final me = ref.watch(ecpClientProvider).me.id;
  final groupId = await ref.watch(groupIdBytesProvider(id).future);
  yield* db.unreadCount(groupId, me).watchSingle();
}

/// Whether any chat has messages of others we have not read.
///
/// The nav bar shows it on every page, so it only follows the client
/// MessengerBootstrap starts for an approved device instead of starting one.
@riverpod
Stream<bool> hasUnread(Ref ref) {
  final device = ref.watch(authProvider).value?.device;
  if (platform.isWeb || !(device?.isApproved ?? false)) {
    return Stream.value(false);
  }
  // ecpClientProvider fails while the client loads, a stream provider just
  // stays loading on requireValue until it is up
  final me = ref.watch(asyncEcpClientProvider).requireValue.me.id;
  return db.hasUnread(me).watch().map((rows) => rows.isNotEmpty);
}

typedef MessageRevision = ({String? content, DateTime since});

/// The earlier contents of an edited message, oldest first.
@riverpod
Stream<List<MessageRevision>> messageRevisions(Ref ref, Uri serverActivityId) {
  final query = db.select(db.messageRevisions)
    ..where((t) => t.messageId.equalsValue(serverActivityId))
    ..orderBy([(t) => OrderingTerm.asc(t.rowId)]);
  return query.watch().map(
    (rows) => [
      for (final row in rows) (content: row.content, since: row.since),
    ],
  );
}

typedef LastMessagePreview = ({
  String? content,
  bool hasAttachment,
  bool deleted,
});

/// The newest message in a group, for the chat list, or null when the group
/// has none yet.
@riverpod
Stream<LastMessagePreview?> lastMessage(Ref ref, int id) async* {
  final groupId = await ref.watch(groupIdBytesProvider(id).future);
  final messages = db.storedMessages;
  final attachments = db.messageAttachments;
  // the join can repeat the message once per attachment, any one of those
  // rows answers whether it has one
  final query =
      db.select(messages).join([
          leftOuterJoin(
            attachments,
            attachments.messageId.equalsExp(messages.serverActivityId),
          ),
        ])
        ..where(messages.groupId.equals(groupId))
        ..orderBy([OrderingTerm.desc(messages.receivedAt)])
        ..limit(1);
  yield* query.watchSingleOrNull().map((row) {
    if (row == null) return null;
    final message = row.readTable(messages);
    return (
      content: message.content,
      hasAttachment: row.readTableOrNull(attachments) != null,
      deleted: message.deleted,
    );
  });
}
