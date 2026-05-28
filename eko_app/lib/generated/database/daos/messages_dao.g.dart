// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../database/daos/messages_dao.dart';

// ignore_for_file: type=lint
mixin _$MessagesDaoMixin on DatabaseAccessor<AppDatabase> {
  $MessagesTable get messages => attachedDatabase.messages;
  $ContactsTable get contacts => attachedDatabase.contacts;
  $ConversationsTable get conversations => attachedDatabase.conversations;
  $MediaTable get media => attachedDatabase.media;
  MessagesDaoManager get managers => MessagesDaoManager(this);
}

class MessagesDaoManager {
  final _$MessagesDaoMixin _db;
  MessagesDaoManager(this._db);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db.attachedDatabase, _db.messages);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db.attachedDatabase, _db.contacts);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db.attachedDatabase, _db.conversations);
  $$MediaTableTableManager get media =>
      $$MediaTableTableManager(_db.attachedDatabase, _db.media);
}
