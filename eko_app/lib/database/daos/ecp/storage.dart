import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:ecp/ecp.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import '../../database.dart';

class _DriftMlsEngineConfigStore implements MlsEngineConfigStore {
  static const _keyName = '${c.appInstanceId}_mls_engine_key';

  @override
  Future<MlsEngineConfig> getConfig() async {
    const secureStorage = FlutterSecureStorage();
    String? storedKey = await secureStorage.read(key: _keyName);
    if (storedKey == null) {
      final random = Random.secure();
      final key = Uint8List(32);
      for (var i = 0; i < 32; i++) {
        key[i] = random.nextInt(256);
      }
      storedKey = base64Encode(key);
      await secureStorage.write(key: _keyName, value: storedKey);
    }
    final dbFolder = await getApplicationSupportDirectory();
    final dbPath = p.join(dbFolder.path, '${c.appInstanceId}_mls.db');
    return MlsEngineConfig(
      dbPath: dbPath,
      encryptionKey: Uint8List.fromList(base64Decode(storedKey)),
    );
  }
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

class _DriftMlsKeyPackageStore implements MlsKeyPackageStore {
  final AppDatabase _db;

  _DriftMlsKeyPackageStore(this._db);

  @override
  Future<List<Uint8List>> getKeyPackages() async {
    final rows = await _db.select(_db.mlsKeyPackages).get();
    return rows.map((r) => r.keyPackage).toList();
  }

  @override
  Future<void> saveKeyPackages(List<Uint8List> keyPackages) async {
    await _db.transaction(() async {
      await _db.delete(_db.mlsKeyPackages).go();
      for (final pkg in keyPackages) {
        await _db
            .into(_db.mlsKeyPackages)
            .insert(MlsKeyPackagesCompanion(keyPackage: Value(pkg)));
      }
    });
  }
}

class _DriftUserStore implements UserStore {
  final AppDatabase _db;

  _DriftUserStore(this._db);

  @override
  Future<int> saveDevice(Uri id, Uri did) async {
    await _db
        .into(_db.users)
        .insertOnConflictUpdate(UsersCompanion(id: Value(id)));
    return await _db.into(_db.userDevices).insertOnConflictUpdate(
          UserDevicesCompanion(userId: Value(id), deviceId: Value(did)),
        );
  }

  @override
  Future<int?> getDevice(Uri did) async {
    final query = _db.select(_db.userDevices)
      ..where((u) => u.deviceId.equals(did.toString()));
    return (await query.getSingleOrNull())?.id;
  }

  @override
  Future<int?> removeDevice(Uri did) async {
    final id = await getDevice(did);
    if (id != null) {
      await (_db.delete(_db.userDevices)..where((u) => u.id.equals(id))).go();
    }
    return id;
  }

  @override
  Future<Map<Uri, int>?> getUser(Uri id) async {
    final result = await (_db.select(_db.userDevices)
          ..where((u) => u.userId.equals(id.toString())))
        .get();
    if (result.isEmpty) return null;
    return {for (final v in result) v.deviceId: v.id};
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

class DriftStorage extends Storage {
  final AppDatabase _db;

  DriftStorage._({
    required AppDatabase db,
    required super.mlsEngineConfigStore,
    required super.mlsCredentialStore,
    required super.mlsKeyPackageStore,
    required super.userStore,
    required super.capabilitiesStore,
  }) : _db = db;

  factory DriftStorage(AppDatabase db) => DriftStorage._(
        db: db,
        mlsEngineConfigStore: _DriftMlsEngineConfigStore(),
        mlsCredentialStore: _DriftMlsCredentialStore(db),
        mlsKeyPackageStore: _DriftMlsKeyPackageStore(db),
        userStore: _DriftUserStore(db),
        capabilitiesStore: _DriftCapabilitiesStore(db),
      );

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
