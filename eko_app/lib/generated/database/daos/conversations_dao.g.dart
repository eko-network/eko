// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../database/daos/conversations_dao.dart';

// ignore_for_file: type=lint
mixin _$ConversationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ContactsTable get contacts => attachedDatabase.contacts;
  $ConversationsTable get conversations => attachedDatabase.conversations;
  ConversationsDaoManager get managers => ConversationsDaoManager(this);
}

class ConversationsDaoManager {
  final _$ConversationsDaoMixin _db;
  ConversationsDaoManager(this._db);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db.attachedDatabase, _db.contacts);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db.attachedDatabase, _db.conversations);
}
