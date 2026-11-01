import 'dart:async';

import 'package:drift/drift.dart';
import 'package:ecp/ecp.dart';
import 'package:eko_app/database/database.dart';
import 'package:eko_app/database/mappers.dart';
import 'package:eko_app/providers/ecp_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part '../../generated/messenger/providers/message_provider.g.dart';

@riverpod
Stream<List<StoredMessage>> message(Ref ref, Uint8List groupId) {
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
  return query.watch().map((rows) {
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
