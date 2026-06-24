import 'dart:io';
import 'package:drift/drift.dart';
import 'package:ecp/ecp.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:flutter/foundation.dart';
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
        messageStore: _DriftMessageStore(_db),
        processedObjectStore: _DriftProcessedObjectStore(_db),
        approvalRequestStore: _DriftApprovalRequestStore(_db),
      );

  @override
  Future<void> clear() async {
    final config = await mlsEngineConfigStore.getConfig();
    await _db.transaction(() async {
      await _db.delete(_db.mlsCredentials).go();
      await _db.delete(_db.mlsKeyPackages).go();
      await _db.delete(_db.capabilities).go();
      await _db.delete(_db.mlsGroups).go();
      await _db.delete(_db.mlsEngineConfigs).go();
      await _db.delete(_db.processedObjects).go();
      await _db.delete(_db.storedMessages).go();
      await _db.delete(_db.messageAttachments).go();
    });
    if (config != null) {
      final file = File(config.dbPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}

class _DriftApprovalRequestStore implements ApprovalRequestStore {
  final AppDatabase _db;
  _DriftApprovalRequestStore(this._db);

  @override
  Future<void> saveApprovalRequest(StoredApprovalRequest request) async {
    await _db
        .into(_db.approvalRequest)
        .insertOnConflictUpdate(
          ApprovalRequestCompanion(
            publicKey: Value(request.publicKey),
            did: Value(request.did),
          ),
        );
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

  @override
  Future<void> clearConfig() async {
    await (_db.delete(
      _db.mlsEngineConfigs,
    )..where((t) => t.id.equals(_singleRowId))).go();
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
  Future<MlsGroupRecord?> getGroupByGroupId(Uint8List id) async {
    final row = await (_db.select(
      _db.mlsGroups,
    )..where((t) => t.groupIdBytes.equals(id))).getSingleOrNull();
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

class _DriftMessageStore implements MessageStore {
  final AppDatabase _db;
  _DriftMessageStore(this._db);

  final _pendingDeliveries = <Uri>{};

  @override
  Future<void> saveMessage(StoredMessage message) async {
    debugPrint('[AppStorage] saving message with content: ${message.content}');
    debugPrint(
      '[AppStorage] saving message with serverActivityId: ${message.serverActivityId}',
    );
    debugPrint('[AppStorage] saving message with id: ${message.id}');

    await _db.transaction(() async {
      final isDelivered =
          message.delivered ||
          _pendingDeliveries.remove(message.serverActivityId);

      await _db
          .into(_db.storedMessages)
          .insertOnConflictUpdate(
            StoredMessagesCompanion.insert(
              serverActivityId: message.serverActivityId,
              groupId: message.groupId,
              receivedAt: message.receivedAt,
              senderId: message.senderId,
              id: message.id,
              content: Value(message.content),
              inReplyTo: Value(message.inReplyTo),
              delivered: Value(isDelivered),
            ),
          );
      for (final attachmentId in message.attachment) {
        await _db
            .into(_db.messageAttachments)
            .insert(
              MessageAttachmentsCompanion.insert(
                messageId: message.serverActivityId,
                attachmentId: attachmentId,
              ),
            );
      }
    });
  }

  @override
  Future<bool> markMessageDelivered(Uri serverActivityId) async {
    // TODO there exists interleavings where the queue is empty when the message comes in and then the delivery message is added to the queue and the delivered query happens before the message is inserted. i dont want to introduce locks bc thats scary. and delivered markings are not very important.
    _pendingDeliveries.add(serverActivityId);

    final count =
        await (_db.update(_db.storedMessages)..where(
              (t) => t.serverActivityId.equals(serverActivityId.toString()),
            ))
            .write(StoredMessagesCompanion(delivered: const Value(true)));
    if (count > 0) {
      _pendingDeliveries.remove(serverActivityId);
    }
    debugPrint(
      '[AppStorage] markMessageDelivered: $serverActivityId -> $count rows',
    );
    return count > 0;
  }
}

class _DriftProcessedObjectStore implements ProcessedObjectStore {
  final AppDatabase _db;
  _DriftProcessedObjectStore(this._db);

  @override
  Future<void> add(Uri id) async {
    await _db
        .into(_db.processedObjects)
        .insertOnConflictUpdate(ProcessedObjectRow(id: id));
  }

  @override
  Future<bool> check(Uri id) async {
    final row = await (_db.select(
      _db.processedObjects,
    )..where((t) => t.id.equals(id.toString()))).getSingleOrNull();
    print("checking if message id: $id exists: $row");
    return row != null;
  }

  @override
  Future<bool> markDelivered(Uri id) async {
    final exists = await (_db.select(
      _db.processedObjects,
    )..where((t) => t.id.equals(id.toString()))).getSingleOrNull();
    if (exists != null) return false;
    await _db.into(_db.processedObjects).insert(ProcessedObjectRow(id: id));
    return true;
  }
}
