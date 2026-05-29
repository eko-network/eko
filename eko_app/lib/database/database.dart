import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:ecp/ecp.dart' hide Capabilities;
import 'package:eko_app/database/type_converters.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
// import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

// Import table definitions
import 'tables/auth.dart';
import 'tables/ecp.dart';

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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

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
    final dbFolder = await getApplicationSupportDirectory();
    final file = File(p.join(dbFolder.path, c.db));

    if (Platform.isLinux) {
      if (await file.exists()) {
        final header = await file.openRead(0, 16).first;
        const sqliteHeader = [
          0x53,
          0x51,
          0x4c,
          0x69,
          0x74,
          0x65,
          0x20,
          0x66,
          0x6f,
          0x72,
          0x6d,
          0x61,
          0x74,
          0x20,
          0x33,
          0x00,
        ];
        final isValidSqlite = header.length >= 16 &&
            List.generate(16, (i) => header[i] == sqliteHeader[i])
                .every((v) => v);
        if (!isValidSqlite) {
          await file.delete();
        }
      }
      return NativeDatabase(file);
    }

    final password = await _getDbPassword();
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
