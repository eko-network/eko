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
  final query = db.select(db.storedMessages)
    ..where((t) => t.groupId.equals(groupId))
    ..orderBy([(u) => OrderingTerm.asc(u.receivedAt)]);
  return query.watch().map((list) {
    final messages = list.map((v) => v.toMessage()).toList();
    unawaited(_sendPendingDeliveryAcks(ref, messages));
    return messages;
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
