import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:ecp/ecp.dart' hide Capabilities;
import 'package:eko_app/database/daos/contacts_dao.dart';
import 'package:eko_app/database/daos/conversations_dao.dart';
import 'package:eko_app/database/tables/contacts.dart';
import 'package:eko_app/database/tables/conversations.dart';
import 'package:eko_app/database/type_converters.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
// import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:uuid/uuid_value.dart';

// Import table definitions
import 'tables/auth.dart';
import 'tables/ecp.dart';
import 'tables/messages.dart';
import 'tables/media.dart';

// Import DAOs
import 'daos/messages_dao.dart';

part '../generated/database/database.g.dart';

@DriftDatabase(
  tables: [
    // ECP
    Capabilities,
    MlsCredentials,
    MlsKeyPackages,
    // Auth
    Users,
    UserDevices,
    AuthInfoTable,
    // Other
    Messages,
    Media,
    Contacts,
    Conversations,
  ],
  daos: [MessagesDao, ContactsDao, ConversationsDao],
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
  final FlutterSecureStorage storage = const FlutterSecureStorage();
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
    // Load SQLCipher for Android
    await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();

    final password = await _getDbPassword();
    final dbFolder = await getApplicationSupportDirectory();
    final file = File(p.join(dbFolder.path, c.db));

    // Open with SQLCipher
    final rawDb = sqlite3.open(file.path, uri: false);

    final result = rawDb.select('PRAGMA cipher_version;');
    if (result.isEmpty) {
      throw StateError('SQLCipher library is not available!');
    }
    rawDb.execute("PRAGMA key = '$password';");
    return NativeDatabase.opened(rawDb);
  });
}

/// Clear the database encryption key from secure storage
Future<void> clearDatabaseEncryptionKey() async {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
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
