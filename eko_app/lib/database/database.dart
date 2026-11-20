import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:ecp/ecp.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'package:eko_app/database/connection.dart';

import 'package:eko_app/utilities/constants.dart' as c;

part '../generated/database/database.g.dart';

// --- Type Converters ---

enum MessageStatus { failed, sending, sent, delivered }

class MessageStatusConverter extends TypeConverter<MessageStatus, int> {
  const MessageStatusConverter();

  @override
  MessageStatus fromSql(int fromDb) => MessageStatus.values[fromDb];

  @override
  int toSql(MessageStatus value) => value.index;
}

class UriTypeConverter extends TypeConverter<Uri, String> {
  const UriTypeConverter();

  @override
  Uri fromSql(String fromDb) => Uri.parse(fromDb);

  @override
  String toSql(Uri value) => value.toString();
}

class UuidValueConverter extends TypeConverter<UuidValue, String> {
  const UuidValueConverter();
  @override
  UuidValue fromSql(String fromDb) => UuidValue.fromString(fromDb);

  @override
  String toSql(UuidValue value) => value.toString();
}

class InternalIdConverter extends TypeConverter<InternalId, String> {
  const InternalIdConverter();
  @override
  InternalId fromSql(String fromDb) => InternalId.fromSerialized(fromDb);
  @override
  String toSql(InternalId value) => value.serialize();
}

class JsonValueConverter extends TypeConverter<Map<String, dynamic>, String> {
  const JsonValueConverter();
  @override
  Map<String, dynamic> fromSql(String fromDb) => jsonDecode(fromDb);

  @override
  String toSql(Map<String, dynamic> value) => jsonEncode(value);
}

// --- Tables ---

@DataClassName('CapabilityRow')
class Capabilities extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get capabilities => text().map(const JsonValueConverter())();
  DateTimeColumn get time => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MlsCredentialRow')
class MlsCredentials extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  BlobColumn get credentialIdentity => blob()();
  BlobColumn get credentialBytes => blob()();
  BlobColumn get signerBytes => blob()();
  BlobColumn get signerPublicKey => blob()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MlsKeyPackageRow')
class MlsKeyPackages extends Table {
  IntColumn get id => integer().autoIncrement()();
  BlobColumn get keyPackage => blob()();
}

@DataClassName('MlsGroupRow')
class MlsGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  BlobColumn get groupIdBytes => blob()();
  TextColumn get displayName => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastActivityAt =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {groupIdBytes},
  ];
}

@DataClassName('ApprovalRequestRow')
class ApprovalRequest extends Table {
  BlobColumn get publicKey => blob()();
  TextColumn get did => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {did};
}

/// Head of each user's device chain last verified, see [DeviceChainStore].
@DataClassName('DeviceChainPinRow')
/// DMs merged into another DM with the same user, see GroupManager.mergeDms.
class MergedGroups extends Table {
  BlobColumn get groupIdBytes => blob()();
  BlobColumn get mergedInto => blob()();

  @override
  Set<Column> get primaryKey => {groupIdBytes};
}

class DeviceChainPins extends Table {
  TextColumn get actor => text().map(const UriTypeConverter())();
  BlobColumn get head => blob()();

  @override
  Set<Column> get primaryKey => {actor};
}

@DataClassName('MlsEngineConfigRow')
class MlsEngineConfigs extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get dbPath => text()();
  BlobColumn get encryptionKey => blob()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProcessedObjectRow')
class ProcessedObjects extends Table {
  TextColumn get id => text().map(const UriTypeConverter())();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('StoredMessageRow')
// chat views and previews read a group's messages by time
@TableIndex(
  name: 'stored_messages_group_received',
  columns: {#groupId, #receivedAt},
)
class StoredMessages extends Table {
  TextColumn get serverActivityId => text().map(const UriTypeConverter())();
  DateTimeColumn get receivedAt => dateTime()();
  TextColumn get senderId => text().map(const UriTypeConverter())();
  TextColumn get id => text().map(const InternalIdConverter())();
  TextColumn get content => text().nullable()();
  BlobColumn get groupId => blob()();
  TextColumn get inReplyTo =>
      text().map(const InternalIdConverter()).nullable()();
  BoolColumn get delivered => boolean().withDefault(const Constant(false))();
  DateTimeColumn get editedAt => dateTime().nullable()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {serverActivityId};

  // replies, reactions, edits and deletes find a message by its object id
  @override
  List<Set<Column>> get uniqueKeys => [
    {groupId, id},
  ];
}

/// The earlier contents of an edited message, see
/// [StoredMessage.editedAt].
@DataClassName('MessageRevisionRow')
class MessageRevisions extends Table {
  IntColumn get rowId => integer().autoIncrement()();
  TextColumn get messageId => text()
      .map(const UriTypeConverter())
      .references(
        StoredMessages,
        #serverActivityId,
        onDelete: KeyAction.cascade,
      )();
  TextColumn get content => text().nullable()();
  // since when this was the content: when it was sent or edited
  DateTimeColumn get since => dateTime()();
}

@DataClassName('MessageReactionRow')
@TableIndex(name: 'message_reactions_group', columns: {#groupId})
class MessageReactions extends Table {
  TextColumn get id => text().map(const InternalIdConverter())();
  BlobColumn get groupId => blob()();
  TextColumn get messageId => text().map(const InternalIdConverter())();
  TextColumn get senderId => text().map(const UriTypeConverter())();
  TextColumn get emoji => text()();
  DateTimeColumn get receivedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {groupId, id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {groupId, messageId, senderId},
  ];
}

/// How far each member read a group, see [ReadCursor].
@DataClassName('ReadCursorRow')
class ReadCursors extends Table {
  BlobColumn get groupId => blob()();
  TextColumn get reader => text().map(const UriTypeConverter())();
  TextColumn get messageId => text().map(const InternalIdConverter())();
  // when this device received that message, what the cursor compares by
  DateTimeColumn get position => dateTime()();

  @override
  Set<Column> get primaryKey => {groupId, reader};
}

@DataClassName('MessageAttachmentRow')
class MessageAttachments extends Table {
  TextColumn get messageId => text()
      .map(const UriTypeConverter())
      .references(
        StoredMessages,
        #serverActivityId,
        onDelete: KeyAction.cascade,
      )();
  TextColumn get attachmentId => text().map(const InternalIdConverter())();
  IntColumn get position => integer().withDefault(const Constant(0))();
  // the full ActivityPub object, needed to render it (url, size, media type)
  TextColumn get object => text().map(const JsonValueConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {messageId, position};
}

// --- Database ---
@DriftDatabase(
  tables: [
    ApprovalRequest,
    Capabilities,
    DeviceChainPins,
    MergedGroups,
    MlsCredentials,
    MlsKeyPackages,
    MlsGroups,
    MlsEngineConfigs,
    ProcessedObjects,
    StoredMessages,
    MessageAttachments,
    MessageRevisions,
    MessageReactions,
    ReadCursors,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {},
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

/// Clear the database encryption key from secure storage
Future<void> clearDatabaseEncryptionKey() async {
  const storage = FlutterSecureStorage();
  final key = c.dbKey;
  await storage.delete(key: key);
}

/// Delete the database file from disk
Future<void> deleteDatabaseFile() async {
  final dbFolder = await getApplicationSupportDirectory();
  final file = File(p.join(dbFolder.path, c.db));
  if (await file.exists()) {
    await file.delete();
  }
}

final db = AppDatabase();
