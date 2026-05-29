import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

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
  IntColumn get id => integer()();
  BlobColumn get groupIdBytes => blob()();
  TextColumn get groupIdHex => text()();
  TextColumn get displayName => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastActivityAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MlsEngineConfigRow')
class MlsEngineConfigs extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get dbPath => text()();
  BlobColumn get encryptionKey => blob()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('UserRow')
class Users extends Table {
  TextColumn get id => text().map(const UriTypeConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('UserDeviceRow')
@TableIndex(name: 'idx_device_id', columns: {#deviceId})
class UserDevices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()
      .references(Users, #id, onDelete: KeyAction.cascade)
      .map(const UriTypeConverter())();
  TextColumn get deviceId => text().unique().map(const UriTypeConverter())();
}

// --- Database ---

@DriftDatabase(
  tables: [
    Capabilities,
    MlsCredentials,
    MlsKeyPackages,
    MlsGroups,
    MlsEngineConfigs,
    Users,
    UserDevices,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

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

Uint8List _generateRandomBytes(int length) {
  final Random random = Random.secure();
  final Uint8List bytes = Uint8List(length);
  for (int i = 0; i < length; i++) {
    bytes[i] = random.nextInt(256);
  }
  return bytes;
}

Future<String> _getDbPassword() async {
  const storage = FlutterSecureStorage();
  final key = c.dbKey;
  final stored = await storage.read(key: key);
  if (stored != null) {
    return stored;
  }

  final password = base64Encode(_generateRandomBytes(32));
  await storage.write(key: key, value: password);
  return password;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory();
    final file = File(p.join(dbFolder.path, c.db));

    debugPrint('[LazyDatabase] opening db: ${file.path}');
    final password = await _getDbPassword();
    final rawDb = sqlite3.open(file.path, uri: false);

    final result = rawDb.select('PRAGMA cipher_version;');
    if (result.isEmpty) {
      throw StateError('SQLCipher/SQLite3MC library is not available!');
    }
    rawDb.execute("PRAGMA key = '$password';");
    return NativeDatabase.opened(rawDb);
  });
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
