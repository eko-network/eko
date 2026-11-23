import 'dart:io';
import 'package:drift/drift.dart';
import 'package:ecp/ecp.dart';
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
        deviceChainStore: _DriftDeviceChainStore(_db),
      );

  @override
  Future<void> clear() async {
    final config = await mlsEngineConfigStore.getConfig();
    await _db.transaction(() async {
      await _db.delete(_db.mlsCredentials).go();
      await _db.delete(_db.mlsKeyPackages).go();
      await _db.delete(_db.capabilities).go();
      await _db.delete(_db.mlsGroups).go();
      await _db.delete(_db.mergedGroups).go();
      await _db.delete(_db.mlsEngineConfigs).go();
      await _db.delete(_db.processedObjects).go();
      await _db.delete(_db.messageAttachments).go();
      await _db.delete(_db.messageRevisions).go();
      await _db.delete(_db.messageReactions).go();
      await _db.delete(_db.readCursors).go();
      await _db.delete(_db.storedMessages).go();
      await _db.delete(_db.deviceChainPins).go();
    });
    if (config != null) {
      final file = File(config.dbPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}

extension MessageDeletion on AppDatabase {
  /// Removes [message] from this device only, others keep it.
  Future<void> deleteMessageForMe(StoredMessage message) =>
      transaction(() async {
        await (delete(messageReactions)..where(
              (t) =>
                  t.groupId.equals(message.groupId) &
                  t.messageId.equalsValue(message.id),
            ))
            .go();
        // attachments and revisions go with it
        await (delete(storedMessages)..where(
              (t) => t.serverActivityId.equalsValue(message.serverActivityId),
            ))
            .go();
      });
}

extension ReadState on AppDatabase {
  /// How many messages of others in [groupId] [me] has not read, see
  /// [ReadCursor].
  Selectable<int> unreadCount(Uint8List groupId, Uri me) {
    final m = storedMessages;
    final count = m.serverActivityId.count();
    final position = subqueryExpression<DateTime>(
      selectOnly(readCursors)
        ..addColumns([readCursors.position])
        ..where(
          readCursors.groupId.equals(groupId) &
              readCursors.reader.equalsValue(me),
        ),
    );
    final query = selectOnly(m)
      ..addColumns([count])
      ..where(
        m.groupId.equals(groupId) &
            m.senderId.equalsValue(me).not() &
            m.deleted.not() &
            (position.isNull() | m.receivedAt.isBiggerThan(position)),
      );
    return query.map((row) => row.read(count)!);
  }

  /// Whether [me] has not read a message of others in any active group, see
  /// [unreadCount].
  Selectable<bool> hasUnread(Uri me) {
    final m = storedMessages;
    final position = subqueryExpression<DateTime>(
      selectOnly(readCursors)
        ..addColumns([readCursors.position])
        ..where(
          readCursors.groupId.equalsExp(m.groupId) &
              readCursors.reader.equalsValue(me),
        ),
    );
    final query =
        selectOnly(m).join([
            innerJoin(
              mlsGroups,
              mlsGroups.groupIdBytes.equalsExp(m.groupId),
              useColumns: false,
            ),
          ])
          ..addColumns([m.serverActivityId])
          ..where(
            mlsGroups.isActive &
                m.senderId.equalsValue(me).not() &
                m.deleted.not() &
                (position.isNull() | m.receivedAt.isBiggerThan(position)),
          )
          ..limit(1);
    return query.map((_) => true);
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

class _DriftDeviceChainStore implements DeviceChainStore {
  final AppDatabase _db;
  _DriftDeviceChainStore(this._db);

  @override
  Future<Uint8List?> getPinnedHead(Uri actor) async {
    final row = await (_db.select(
      _db.deviceChainPins,
    )..where((t) => t.actor.equals(actor.toString()))).getSingleOrNull();
    return row?.head;
  }

  @override
  Future<void> pinHead(Uri actor, Uint8List head) async {
    await _db
        .into(_db.deviceChainPins)
        .insertOnConflictUpdate(
          DeviceChainPinsCompanion(actor: Value(actor), head: Value(head)),
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
  Future<List<MlsGroupRecord>> getActiveGroups() async {
    final rows = await (_db.select(
      _db.mlsGroups,
    )..where((t) => t.isActive.equals(true))).get();
    return rows.map((r) => r.toRecord()).toList();
  }

  @override
  Future<List<MlsGroupRecord>> getHiddenGroups() async {
    final rows = await (_db.select(
      _db.mlsGroups,
    )..where((t) => t.isActive.equals(false))).get();
    return rows.map((r) => r.toRecord()).toList();
  }

  @override
  Future<void> saveGroup({
    required Uint8List groupIdBytes,
    String? displayName,
    bool isActive = true,
  }) async {
    final row = MlsGroupsCompanion(
      groupIdBytes: Value(groupIdBytes),
      displayName: Value.absentIfNull(displayName),
      isActive: Value(isActive),
    );
    // the id is autoincremented, so the conflict has to be on the group id
    await _db
        .into(_db.mlsGroups)
        .insert(
          row,
          onConflict: DoUpdate(
            (_) => row,
            target: [_db.mlsGroups.groupIdBytes],
          ),
        );
  }

  @override
  Future<void> setGroupActive(Uint8List groupIdBytes, bool isActive) async {
    await (_db.update(_db.mlsGroups)
          ..where((t) => t.groupIdBytes.equals(groupIdBytes)))
        .write(MlsGroupsCompanion(isActive: Value(isActive)));
  }

  @override
  Future<void> deleteGroup(Uint8List groupIdBytes) async {
    await (_db.delete(
      _db.mlsGroups,
    )..where((t) => t.groupIdBytes.equals(groupIdBytes))).go();
  }

  @override
  Future<void> mergeGroup({
    required Uint8List from,
    required Uint8List into,
  }) async {
    await _db.transaction(() async {
      await (_db.update(_db.mergedGroups)
            ..where((t) => t.mergedInto.equals(from)))
          .write(MergedGroupsCompanion(mergedInto: Value(into)));
      await _db
          .into(_db.mergedGroups)
          .insertOnConflictUpdate(
            MergedGroupsCompanion(
              groupIdBytes: Value(from),
              mergedInto: Value(into),
            ),
          );
      await deleteGroup(from);
    });
  }

  @override
  Future<Uint8List?> getMergedInto(Uint8List groupIdBytes) async {
    final row = await (_db.select(
      _db.mergedGroups,
    )..where((t) => t.groupIdBytes.equals(groupIdBytes))).getSingleOrNull();
    return row?.mergedInto;
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
      await _bumpActivity(message.groupId, message.receivedAt);
      await (_db.delete(_db.messageAttachments)..where(
            (t) => t.messageId.equals(message.serverActivityId.toString()),
          ))
          .go();
      for (final (index, attachment) in message.attachment.indexed) {
        await _db
            .into(_db.messageAttachments)
            .insert(
              MessageAttachmentsCompanion.insert(
                messageId: message.serverActivityId,
                attachmentId: attachment.id,
                position: Value(index),
                object: Value(attachment.toJson()),
              ),
            );
      }
    });
  }

  /// Moves [groupId]'s last activity up to [at], never back, as a message can
  /// come in after newer ones.
  Future<void> _bumpActivity(Uint8List groupId, DateTime at) async {
    await (_db.update(_db.mlsGroups)..where(
          (t) =>
              t.groupIdBytes.equals(groupId) &
              t.lastActivityAt.isSmallerThanValue(at),
        ))
        .write(MlsGroupsCompanion(lastActivityAt: Value(at)));
  }

  @override
  Future<bool> hasMessage(Uri serverActivityId) async {
    final row =
        await (_db.select(_db.storedMessages)..where(
              (t) => t.serverActivityId.equals(serverActivityId.toString()),
            ))
            .getSingleOrNull();
    return row != null;
  }

  @override
  Future<StoredMessage?> getMessage(Uint8List groupId, InternalId id) async {
    final row = await _message(groupId, id).getSingleOrNull();
    return row?.toMessage(await _attachments(row.serverActivityId));
  }

  SimpleSelectStatement<$StoredMessagesTable, StoredMessageRow> _message(
    Uint8List groupId,
    InternalId id,
  ) =>
      _db.select(_db.storedMessages)
        ..where((t) => t.groupId.equals(groupId) & t.id.equalsValue(id));

  Future<List<ActivityPubObject>> _attachments(Uri messageId) async {
    final rows =
        await (_db.select(_db.messageAttachments)
              ..where((t) => t.messageId.equalsValue(messageId))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    return [
      for (final row in rows)
        if (row.object != null) ActivityPubObject.fromJson(row.object!),
    ];
  }

  @override
  Future<void> editMessage(
    Uint8List groupId,
    InternalId id, {
    required String? content,
    required DateTime editedAt,
  }) async {
    await _db.transaction(() async {
      final row = await _message(groupId, id).getSingleOrNull();
      if (row == null) return;
      await _db
          .into(_db.messageRevisions)
          .insert(
            MessageRevisionsCompanion.insert(
              messageId: row.serverActivityId,
              content: Value(row.content),
              since: row.editedAt ?? row.receivedAt,
            ),
          );
      await (_db.update(
            _db.storedMessages,
          )..where((t) => t.serverActivityId.equalsValue(row.serverActivityId)))
          .write(
            StoredMessagesCompanion(
              content: Value(content),
              editedAt: Value(editedAt),
            ),
          );
    });
  }

  @override
  Future<void> deleteMessage(Uint8List groupId, InternalId id) async {
    await _db.transaction(() async {
      final row = await _message(groupId, id).getSingleOrNull();
      if (row == null) return;
      final messageId = row.serverActivityId;
      await (_db.delete(
        _db.messageAttachments,
      )..where((t) => t.messageId.equalsValue(messageId))).go();
      await (_db.delete(
        _db.messageRevisions,
      )..where((t) => t.messageId.equalsValue(messageId))).go();
      await (_db.delete(_db.messageReactions)..where(
            (t) => t.groupId.equals(groupId) & t.messageId.equalsValue(id),
          ))
          .go();
      await (_db.update(
        _db.storedMessages,
      )..where((t) => t.serverActivityId.equalsValue(messageId))).write(
        const StoredMessagesCompanion(
          content: Value(null),
          deleted: Value(true),
        ),
      );
    });
  }

  @override
  Future<void> saveReaction(StoredReaction reaction) async {
    await _db.transaction(() async {
      await (_db.delete(_db.messageReactions)..where(
            (t) =>
                t.groupId.equals(reaction.groupId) &
                t.messageId.equalsValue(reaction.messageId) &
                t.senderId.equalsValue(reaction.senderId),
          ))
          .go();
      await _db
          .into(_db.messageReactions)
          .insertOnConflictUpdate(
            MessageReactionsCompanion.insert(
              id: reaction.id,
              groupId: reaction.groupId,
              messageId: reaction.messageId,
              senderId: reaction.senderId,
              emoji: reaction.emoji,
              receivedAt: reaction.receivedAt,
            ),
          );
    });
  }

  @override
  Future<StoredReaction?> getReaction(Uint8List groupId, InternalId id) async {
    final row = await _reaction(groupId, id).getSingleOrNull();
    return row?.toReaction();
  }

  SimpleSelectStatement<$MessageReactionsTable, MessageReactionRow> _reaction(
    Uint8List groupId,
    InternalId id,
  ) =>
      _db.select(_db.messageReactions)
        ..where((t) => t.groupId.equals(groupId) & t.id.equalsValue(id));

  @override
  Future<void> deleteReaction(Uint8List groupId, InternalId id) async {
    await (_db.delete(
      _db.messageReactions,
    )..where((t) => t.groupId.equals(groupId) & t.id.equalsValue(id))).go();
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

  @override
  Future<ReadCursor?> getReadCursor(Uint8List groupId, Uri reader) async {
    final row = await _cursor(groupId, reader).getSingleOrNull();
    return row?.toCursor();
  }

  SimpleSelectStatement<$ReadCursorsTable, ReadCursorRow> _cursor(
    Uint8List groupId,
    Uri reader,
  ) => _db.select(_db.readCursors)
    ..where((t) => t.groupId.equals(groupId) & t.reader.equalsValue(reader));

  @override
  Future<ReadCursor?> advanceReadCursor(
    Uint8List groupId,
    Uri reader,
    InternalId messageId,
  ) {
    return _db.transaction(() async {
      final message = await _message(groupId, messageId).getSingleOrNull();
      if (message == null) return null;
      final current = await _cursor(groupId, reader).getSingleOrNull();
      if (current != null && !message.receivedAt.isAfter(current.position)) {
        return null;
      }
      final row = ReadCursorRow(
        groupId: groupId,
        reader: reader,
        messageId: messageId,
        position: message.receivedAt,
      );
      await _db.into(_db.readCursors).insertOnConflictUpdate(row);
      return row.toCursor();
    });
  }

  @override
  Future<void> moveMessages({
    required Uint8List from,
    required Uint8List to,
  }) async {
    await _db.transaction(() async {
      final m = _db.storedMessages;
      final newest = m.receivedAt.max();
      final newestMoved =
          await (_db.selectOnly(m)
                ..addColumns([newest])
                ..where(m.groupId.equals(from)))
              .map((row) => row.read(newest))
              .getSingle();
      await (_db.update(_db.storedMessages)
            ..where((t) => t.groupId.equals(from)))
          .write(StoredMessagesCompanion(groupId: Value(to)));
      if (newestMoved != null) await _bumpActivity(to, newestMoved);
      await (_db.update(_db.messageReactions)
            ..where((t) => t.groupId.equals(from)))
          .write(MessageReactionsCompanion(groupId: Value(to)));
      final moved = await (_db.select(
        _db.readCursors,
      )..where((t) => t.groupId.equals(from))).get();
      await (_db.delete(
        _db.readCursors,
      )..where((t) => t.groupId.equals(from))).go();
      for (final cursor in moved) {
        final kept = await _cursor(to, cursor.reader).getSingleOrNull();
        if (kept != null && !cursor.position.isAfter(kept.position)) continue;
        await _db
            .into(_db.readCursors)
            .insertOnConflictUpdate(cursor.copyWith(groupId: to));
      }
    });
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
    print('checking if message id: $id exists: $row');
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
