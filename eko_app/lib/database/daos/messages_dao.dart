import 'package:drift/drift.dart';
import 'package:ecp/ecp.dart';
import 'package:eko_app/database/tables/conversations.dart';
import 'package:eko_app/database/type_converters.dart';
import 'package:uuid/uuid_value.dart';
import 'package:flutter/foundation.dart';

import '../database.dart';
import '../tables/messages.dart';
import '../tables/media.dart';
import '../models/message_with_attachments.dart';

part '../../generated/database/daos/messages_dao.g.dart';

@DriftAccessor(tables: [Messages, Conversations, Media])
class MessagesDao extends DatabaseAccessor<AppDatabase>
    with _$MessagesDaoMixin {
  MessagesDao(super.db);

  Future<void> insertNewMessage(
    ActivityPubObject message,
    MessageStatus status, {
    required Uri from,
    required Uri to,
  }) async {
    debugPrint("insertNewMessage called");
    String? content;
    List<Image> images = [];

    if (message is Note) {
      content = message.content;
      if (message.attachments != null) {
        for (final attachment in message.attachments!) {
          debugPrint('Attachment runtime type: ${attachment.runtimeType}');
        }
        images = message.attachments!.whereType<Image>().toList();
      }
    } else if (message is Image) {
      images.add(message);
    }

    await into(messages).insert(
      MessagesCompanion(
        id: Value(message.base.id),
        to: Value(to),
        from: Value(from),
        content: Value(content),
        time: Value(DateTime.now()),
        status: Value(status),
      ),
    );

    for (final img in images) {
      debugPrint('saving ${images.length} media items');
      await into(media).insert(
        MediaCompanion(
          messageId: Value(message.base.id),
          url: Value(img.url),
          width: Value(img.width),
          height: Value(img.height),
          contentType: Value(img.mediaType),
        ),
      );
    }

    // probably shoudl move to id
    final snippet = (content != null && content.isNotEmpty)
        ? content.replaceAll("\n", " ")
        : (images.isNotEmpty ? "📷 Image" : "");

    await (update(
      conversations,
    )..where((tbl) => tbl.participant.equals(to.toString())))
        .write(
      ConversationsCompanion(
        lastMessageTime: Value(DateTime.now()),
        lastMessageContent: Value(snippet),
      ),
    );
  }

  Future<void> markMessageSent(UuidValue messageId, Uri envelopeId) async {
    await (update(
      messages,
    )..where((tbl) => tbl.id.equals(messageId.toString())))
        .write(
      MessagesCompanion(
        status: Value(MessageStatus.sent),
        envelopeId: Value(envelopeId),
      ),
    );
  }

  Future<void> updateMessageStatusFromId(
    UuidValue messageId,
    MessageStatus status,
  ) async {
    await (update(messages)
          ..where((tbl) => tbl.id.equals(messageId.toString())))
        .write(MessagesCompanion(status: Value(status)));
  }

  Future<void> updateMessageStatusFromEnvelope(
    Uri envelopeId,
    MessageStatus status,
  ) async {
    await (update(messages)
          ..where((tbl) => tbl.envelopeId.equals(envelopeId.toString())))
        .write(MessagesCompanion(status: Value(status)));
  }

  Stream<List<MessageWithAttachments>>
      watchMessagesWithAttachmentForConversation(Uri contactId, Uri myId) {
    final query = select(
      messages,
    ).join([leftOuterJoin(media, media.messageId.equalsExp(messages.id))])
      ..where(
        (messages.to.equals('$contactId') & messages.from.equals('$myId')) |
            (messages.from.equals('$contactId') & messages.to.equals('$myId')),
      )
      ..orderBy([OrderingTerm.asc(messages.time)]);

    return query.watch().map((rows) {
      final Map<Message, List<MediaData>> groupedData = {};

      for (final row in rows) {
        final message = row.readTable(messages);
        final mediaItem = row.readTableOrNull(media);

        if (!groupedData.containsKey(message)) {
          groupedData[message] = [];
        }
        if (mediaItem != null) {
          groupedData[message]!.add(mediaItem);
        }
      }

      return groupedData.entries
          .map(
            (entry) => MessageWithAttachments(
              message: entry.key,
              attachments: entry.value,
            ),
          )
          .toList();
    });
  }
}
