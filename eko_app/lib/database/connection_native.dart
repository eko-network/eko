import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:eko_app/utilities/ecp_db_path.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'package:eko_app/utilities/constants.dart' as c;

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
    // Ensure the extension can read it via shared file
    await _writeSharedDbKeyFile(stored);
    return stored;
  }

  final password = base64Encode(_generateRandomBytes(32));
  await storage.write(key: key, value: password);
  await _writeSharedDbKeyFile(password);
  return password;
}

/// Write the db encryption key to a file in the App Group container
/// FIXME should be in FlutterSecureStorage...
/// and then the ios notification service needs to read from there
Future<void> _writeSharedDbKeyFile(String value) async {
  final appGroupPath = await getDbPath();
  final file = File(p.join(appGroupPath, '.ecp_db_key'));
  await file.writeAsString(value);
}

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final ecpDbPath = await getDbPath();
    final dbFolder = Directory(ecpDbPath);
    if (!await dbFolder.exists()) {
      await dbFolder.create(recursive: true);
    }
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
