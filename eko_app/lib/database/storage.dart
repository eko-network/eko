import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ecp/ecp.dart';
import 'database.dart';
import 'mappers.dart';

class AppStorage extends Storage {
  final AppDatabase _db;

  AppStorage(this._db)
    : super(
        mlsEngineConfigStore: _DriftMlsEngineConfigStore(_db),
        mlsCredentialStore: _DriftMlsCredentialStore(_db),
        capabilitiesStore: _DriftCapabilitiesStore(_db),
        groupStore: _DriftGroupStore(_db),
      );

  @override
  Future<void> clear() async {
    await _db.transaction(() async {
      await _db.delete(_db.mlsCredentials).go();
      await _db.delete(_db.mlsKeyPackages).go();
      await _db.delete(_db.capabilities).go();
      await _db.delete(_db.mlsGroups).go();
      await _db.delete(_db.mlsEngineConfigs).go();
    });
  }
}

class _DriftMlsEngineConfigStore implements MlsEngineConfigStore {
  final AppDatabase _db;
  static const int _singleRowId = 1;

  _DriftMlsEngineConfigStore(this._db);

  @override
  Future<MlsEngineConfig?> getConfig() async {
    final row = await (_db.select(
      _db.mlsEngineConfigs,
    )..where((t) => t.id.equals(_singleRowId))).getSingleOrNull();
    return row?.toConfig();
  }

  @override
  Future<void> saveConfig(MlsEngineConfig config) async {
    await _db
        .into(_db.mlsEngineConfigs)
        .insertOnConflictUpdate(
          MlsEngineConfigRow(
            id: _singleRowId,
            dbPath: config.dbPath,
            encryptionKey: config.encryptionKey,
          ),
        );
  }
}

class _DriftMlsCredentialStore implements MlsCredentialStore {
  final AppDatabase _db;
  static const int _singleRowId = 1;

  _DriftMlsCredentialStore(this._db);

  @override
  Future<MlsCredentialRecord?> getCredential() async {
    final row = await (_db.select(
      _db.mlsCredentials,
    )..where((t) => t.id.equals(_singleRowId))).getSingleOrNull();
    return row?.toRecord();
  }

  @override
  Future<void> saveCredential(MlsCredentialRecord record) async {
    await _db
        .into(_db.mlsCredentials)
        .insertOnConflictUpdate(
          MlsCredentialRow(
            id: _singleRowId,
            credentialIdentity: record.credentialIdentity,
            credentialBytes: record.credentialBytes,
            signerBytes: record.signerBytes,
            signerPublicKey: record.signerPublicKey,
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
    final row = await (_db.select(
      _db.capabilities,
    )..where((i) => i.id.equals(_singleRowId))).getSingleOrNull();
    if (row == null) return null;
    return (capabilities: row.capabilities, timestamp: row.time);
  }

  @override
  Future<void> saveCapabilities(Map<String, dynamic> capabilities) async {
    await _db
        .into(_db.capabilities)
        .insertOnConflictUpdate(
          CapabilityRow(
            id: _singleRowId,
            capabilities: capabilities,
            time: DateTime.now(),
          ),
        );
  }
}

class _DriftGroupStore implements GroupStore {
  final AppDatabase _db;
  _DriftGroupStore(this._db);

  @override
  Future<MlsGroupRecord?> getGroup(int id) async {
    final row = await (_db.select(
      _db.mlsGroups,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row?.toRecord();
  }

  @override
  Future<void> saveGroup({
    required Uint8List groupIdBytes,
    String? displayName,
  }) async {
    await _db
        .into(_db.mlsGroups)
        .insertOnConflictUpdate(
          MlsGroupsCompanion(
            groupIdBytes: Value(groupIdBytes),
            displayName: Value.absentIfNull(displayName),
          ),
        );
  }
}
