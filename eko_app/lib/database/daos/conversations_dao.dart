import 'package:drift/drift.dart';
import 'package:ecp/ecp.dart';
import 'package:eko_app/database/tables/contacts.dart';
import 'package:eko_app/database/tables/conversations.dart';

import '../database.dart';

part '../../generated/database/daos/conversations_dao.g.dart';

class ConversationWithContact {
  final Conversation conversation;
  final Person contact;

  ConversationWithContact({required this.conversation, required this.contact});
}

@DriftAccessor(tables: [Conversations, Contacts])
class ConversationsDao extends DatabaseAccessor<AppDatabase>
    with _$ConversationsDaoMixin {
  ConversationsDao(super.db);

  Future<int> insertNewConversation(ConversationsCompanion conversation) {
    return into(conversations).insert(conversation);
  }

  Future<Conversation?> getConversationByParticipant(Uri participant) {
    return (select(conversations)
          ..where((c) => c.participant.equals(participant.toString())))
        .getSingleOrNull();
  }

  Future<List<ConversationWithContact>> getConversationsWithContact() {
    return (select(conversations)
          ..orderBy([
            (u) => OrderingTerm(expression: u.id, mode: OrderingMode.desc),
          ]))
        .join([
          leftOuterJoin(
            contacts,
            contacts.id.equalsExp(conversations.participant),
          ),
        ])
        .get()
        .then((value) {
          return value.map((row) {
            return ConversationWithContact(
              conversation: row.readTable(conversations),
              contact: row.readTable(contacts),
            );
          }).toList();
        });
  }

  Stream<List<ConversationWithContact>> watchConversationsWithContact() {
    return (select(conversations)
          ..orderBy([
            (u) => OrderingTerm(
                  expression: u.lastMessageTime,
                  mode: OrderingMode.desc,
                ),
          ]))
        .join([
          leftOuterJoin(
            contacts,
            contacts.id.equalsExp(conversations.participant),
          ),
        ])
        .watch()
        .map((rows) {
          return rows.map((row) {
            return ConversationWithContact(
              conversation: row.readTable(conversations),
              contact: row.readTable(contacts),
            );
          }).toList();
        });
  }
}
