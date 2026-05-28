import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:ecp/ecp.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../database.dart';

class _DriftMlsEngineConfigStore implements MlsEngineConfigStore {
  @override
  Future<MlsEngineConfig?> getConfig() {
    // TODO: implement getConfig
    throw UnimplementedError();
  }

  @override
  Future<void> saveConfig(MlsEngineConfig config) {
    // TODO: implement saveConfig
    throw UnimplementedError();
  }
  // static const _keyName = 'mls_engine_key';
  //
  // @override
  // Future<MlsEngineConfig?> getConfig() async {
  //   const secureStorage = FlutterSecureStorage();
  //   String? storedKey = await secureStorage.read(key: _keyName);
  //   if (storedKey == null) {
  //     final random = Random.secure();
  //     final key = Uint8List(32);
  //     for (var i = 0; i < 32; i++) {
  //       key[i] = random.nextInt(256);
  //     }
  //     storedKey = base64Encode(key);
  //     await secureStorage.write(key: _keyName, value: storedKey);
  //   }
  //   final dbPath = 'mls.db';
  //   return MlsEngineConfig(
  //     dbPath: dbPath,
  //     encryptionKey: Uint8List.fromList(base64Decode(storedKey)),
  //   );
  // }
  //
  // @override
  // Future<void> saveConfig(MlsEngineConfig config) async {
  //   const secureStorage = FlutterSecureStorage();
  //   String? storedKey = await secureStorage.read(key: _keyName);
  //   if (storedKey == null) {
  //     final random = Random.secure();
  //     final key = Uint8List(32);
  //     for (var i = 0; i < 32; i++) {
  //       key[i] = random.nextInt(256);
  //     }
  //     storedKey = base64Encode(key);
  //     await secureStorage.write(key: _keyName, value: storedKey);
  //   }
  //   final dbPath = 'mls.db';
  //   return MlsEngineConfig(
  //     dbPath: dbPath,
  //     encryptionKey: Uint8List.fromList(base64Decode(storedKey)),
  //   );
  // }
}

class _DriftMlsCredentialStore implements MlsCredentialStore {
  final AppDatabase _db;
  static const int _singleRowId = 1;

  _DriftMlsCredentialStore(this._db);

  @override
  Future<MlsCredentialRecord?> getCredential() async {
    final row = await (_db.select(_db.mlsCredentials)
          ..where((t) => t.id.equals(_singleRowId)))
        .getSingleOrNull();
    if (row == null) return null;
    return MlsCredentialRecord(
      credentialIdentity: row.credentialIdentity,
      credentialBytes: row.credentialBytes,
      signerBytes: row.signerBytes,
      signerPublicKey: row.signerPublicKey,
    );
  }

  @override
  Future<void> saveCredential(MlsCredentialRecord record) async {
    await _db.into(_db.mlsCredentials).insertOnConflictUpdate(
          MlsCredentialsCompanion(
            id: const Value(_singleRowId),
            credentialIdentity: Value(record.credentialIdentity),
            credentialBytes: Value(record.credentialBytes),
            signerBytes: Value(record.signerBytes),
            signerPublicKey: Value(record.signerPublicKey),
          ),
        );
  }
}

class _DriftCapabilitiesStore implements CapabilitiesStore {
  final AppDatabase _db;
  static const int _singleRowId = 1;

  _DriftCapabilitiesStore(this._db);

  @override
  Future<CapabilitiesWithTime?> getCapabilities() async {
    final row = await (_db.select(_db.capabilities)
          ..where((i) => i.id.equals(_singleRowId)))
        .getSingleOrNull();
    if (row == null) return null;
    return (capabilities: row.capabilities, timestamp: row.time);
  }

  @override
  Future<void> saveCapabilities(Map<String, dynamic> capabilities) async {
    await _db.into(_db.capabilities).insertOnConflictUpdate(
          CapabilitiesCompanion(
            id: const Value(_singleRowId),
            capabilities: Value(capabilities),
            time: Value(DateTime.now()),
          ),
        );
  }
}

class _DriftGroupStore implements GroupStore {
  final AppDatabase _db;
  _DriftGroupStore(this._db);

  @override
  Future<void> deleteGroup(String id) {
    // TODO: implement deleteGroup
    throw UnimplementedError();
  }

  @override
  Future<MlsGroupRecord?> getGroup(int id) {
    // TODO: implement getGroup
    throw UnimplementedError();
  }

  @override
  Future<List<MlsGroupRecord>> listGroups({bool activeOnly = true}) {
    // TODO: implement listGroups
    throw UnimplementedError();
  }

  @override
  Future<void> markInactive(String id) {
    // TODO: implement markInactive
    throw UnimplementedError();
  }

  @override
  Future<void> saveGroup(MlsGroupRecord record) {
    // TODO: implement saveGroup
    throw UnimplementedError();
  }

  //
  // @override
  // Future<CapabilitiesWithTime?> getCapabilities() async {
  //   final row = await (_db.select(_db.capabilities)
  //         ..where((i) => i.id.equals(_singleRowId)))
  //       .getSingleOrNull();
  //   if (row == null) return null;
  //   return (capabilities: row.capabilities, timestamp: row.time);
  // }
  //
  // @override
  // Future<void> saveCapabilities(Map<String, dynamic> capabilities) async {
  //   await _db.into(_db.capabilities).insertOnConflictUpdate(
  //         CapabilitiesCompanion(
  //           id: const Value(_singleRowId),
  //           capabilities: Value(capabilities),
  //           time: Value(DateTime.now()),
  //         ),
  //       );
  // }
}

class DriftStorage extends Storage {
  final AppDatabase _db;

  DriftStorage._({
    required AppDatabase db,
    required super.mlsEngineConfigStore,
    required super.mlsCredentialStore,
    required super.capabilitiesStore,
    required super.groupStore,
  }) : _db = db;

  factory DriftStorage(AppDatabase db) => DriftStorage._(
      db: db,
      mlsEngineConfigStore: _DriftMlsEngineConfigStore(),
      mlsCredentialStore: _DriftMlsCredentialStore(db),
      capabilitiesStore: _DriftCapabilitiesStore(db),
      groupStore: _DriftGroupStore(db));

  @override
  Future<void> clear() async {
    await _db.transaction(() async {
      await _db.delete(_db.mlsCredentials).go();
      await _db.delete(_db.mlsKeyPackages).go();
      await _db.delete(_db.capabilities).go();
      await _db.delete(_db.userDevices).go();
      await _db.delete(_db.users).go();
    });
  }
}
