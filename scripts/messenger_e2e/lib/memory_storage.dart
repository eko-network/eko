import 'dart:convert';
import 'dart:typed_data';

import 'package:ecp/ecp.dart';

/// In-memory implementation of the SDK storage, one per simulated device.
class MemoryStorage extends Storage {
  MemoryStorage()
    : super(
        mlsEngineConfigStore: _EngineConfigStore(),
        mlsCredentialStore: _CredentialStore(),
        capabilitiesStore: _CapabilitiesStore(),
        groupStore: _GroupStore(),
        messageStore: _MessageStore(),
        processedObjectStore: _ProcessedObjectStore(),
        approvalRequestStore: _ApprovalRequestStore(),
        deviceChainStore: _DeviceChainStore(),
      );

  List<StoredMessage> get messages => (messageStore as _MessageStore).messages;
  List<StoredReaction> get reactions =>
      (messageStore as _MessageStore).reactions;
  List<MlsGroupRecord> get groups => (groupStore as _GroupStore).groups;
  List<StoredApprovalRequest> get approvalRequests =>
      (approvalRequestStore as _ApprovalRequestStore).requests;

  @override
  Future<void> clear() async {
    messages.clear();
    reactions.clear();
    groups.clear();
    (groupStore as _GroupStore).mergedInto.clear();
    approvalRequests.clear();
    (deviceChainStore as _DeviceChainStore).heads.clear();
  }
}

class _EngineConfigStore implements MlsEngineConfigStore {
  MlsEngineConfig? _config;

  @override
  Future<MlsEngineConfig?> getConfig() async => _config;

  @override
  Future<void> saveConfig(MlsEngineConfig config) async => _config = config;

  @override
  Future<void> clearConfig() async => _config = null;
}

class _CredentialStore implements MlsCredentialStore {
  MlsCredentialRecord? _record;

  @override
  Future<MlsCredentialRecord?> getCredential() async => _record;

  @override
  Future<void> saveCredential(MlsCredentialRecord record) async =>
      _record = record;
}

class _CapabilitiesStore implements CapabilitiesStore {
  CapabilitiesWithTime? _value;

  @override
  Future<CapabilitiesWithTime?> getCapabilities() async => _value;

  @override
  Future<void> saveCapabilities(Map<String, dynamic> capabilities) async =>
      _value = (capabilities: capabilities, timestamp: DateTime.now());
}

class _GroupStore implements GroupStore {
  final groups = <MlsGroupRecord>[];
  final mergedInto = <String, Uint8List>{};
  var _nextId = 1;

  @override
  Future<void> saveGroup({
    required Uint8List groupIdBytes,
    String? displayName,
    bool isActive = true,
  }) async {
    if (await getGroupByGroupId(groupIdBytes) != null) return;
    groups.add(
      MlsGroupRecord(
        id: _nextId++,
        groupIdBytes: groupIdBytes,
        displayName: displayName,
        createdAt: DateTime.now(),
        isActive: isActive,
      ),
    );
  }

  @override
  Future<void> setGroupActive(Uint8List groupIdBytes, bool isActive) async {
    final i = groups.indexWhere(
      (g) => bytesEqual(g.groupIdBytes, groupIdBytes),
    );
    if (i < 0) return;
    final g = groups[i];
    groups[i] = MlsGroupRecord(
      id: g.id,
      groupIdBytes: g.groupIdBytes,
      displayName: g.displayName,
      createdAt: g.createdAt,
      lastActivityAt: g.lastActivityAt,
      isActive: isActive,
    );
  }

  @override
  Future<void> deleteGroup(Uint8List groupIdBytes) async =>
      groups.removeWhere((g) => bytesEqual(g.groupIdBytes, groupIdBytes));

  @override
  Future<List<MlsGroupRecord>> getHiddenGroups() async =>
      groups.where((g) => !g.isActive).toList();

  @override
  Future<MlsGroupRecord?> getGroup(int id) async =>
      groups.where((g) => g.id == id).firstOrNull;

  @override
  Future<MlsGroupRecord?> getGroupByGroupId(Uint8List groupIdBytes) async =>
      groups.where((g) => bytesEqual(g.groupIdBytes, groupIdBytes)).firstOrNull;

  @override
  Future<List<MlsGroupRecord>> getActiveGroups() async =>
      groups.where((g) => g.isActive).toList();

  @override
  Future<void> mergeGroup({
    required Uint8List from,
    required Uint8List into,
  }) async {
    for (final key in mergedInto.keys.toList()) {
      if (bytesEqual(mergedInto[key]!, from)) mergedInto[key] = into;
    }
    mergedInto[base64Encode(from)] = into;
    await deleteGroup(from);
  }

  @override
  Future<Uint8List?> getMergedInto(Uint8List groupIdBytes) async =>
      mergedInto[base64Encode(groupIdBytes)];
}

class _MessageStore implements MessageStore {
  final messages = <StoredMessage>[];
  final reactions = <StoredReaction>[];
  // by base64 group id, then reader
  final cursors = <String, Map<Uri, ReadCursor>>{};

  @override
  Future<void> saveMessage(StoredMessage message) async =>
      messages.add(message);

  @override
  Future<bool> hasMessage(Uri serverActivityId) async =>
      messages.any((m) => m.serverActivityId == serverActivityId);

  @override
  Future<StoredMessage?> getMessage(Uint8List groupId, InternalId id) async =>
      messages
          .where((m) => m.id == id && bytesEqual(m.groupId, groupId))
          .firstOrNull;

  @override
  Future<void> editMessage(
    Uint8List groupId,
    InternalId id, {
    required String? content,
    required DateTime editedAt,
  }) async {
    for (final (i, m) in messages.indexed.toList()) {
      if (m.id != id || !bytesEqual(m.groupId, groupId)) continue;
      messages[i] = _copy(m, content: content, editedAt: editedAt);
    }
  }

  @override
  Future<void> deleteMessage(Uint8List groupId, InternalId id) async {
    reactions.removeWhere(
      (r) => r.messageId == id && bytesEqual(r.groupId, groupId),
    );
    for (final (i, m) in messages.indexed.toList()) {
      if (m.id != id || !bytesEqual(m.groupId, groupId)) continue;
      messages[i] = _copy(m, content: null, deleted: true);
    }
  }

  @override
  Future<void> saveReaction(StoredReaction reaction) async {
    reactions
      ..removeWhere(
        (r) =>
            r.messageId == reaction.messageId &&
            r.senderId == reaction.senderId &&
            bytesEqual(r.groupId, reaction.groupId),
      )
      ..add(reaction);
  }

  @override
  Future<StoredReaction?> getReaction(Uint8List groupId, InternalId id) async =>
      reactions
          .where((r) => r.id == id && bytesEqual(r.groupId, groupId))
          .firstOrNull;

  @override
  Future<void> deleteReaction(Uint8List groupId, InternalId id) async =>
      reactions.removeWhere(
        (r) => r.id == id && bytesEqual(r.groupId, groupId),
      );

  @override
  Future<bool> markMessageDelivered(Uri serverActivityId) async {
    var found = false;
    for (final (i, m) in messages.indexed.toList()) {
      if (m.serverActivityId != serverActivityId) continue;
      messages[i] = _copy(m, delivered: true);
      found = true;
    }
    return found;
  }

  @override
  Future<ReadCursor?> getReadCursor(Uint8List groupId, Uri reader) async =>
      cursors[base64Encode(groupId)]?[reader];

  @override
  Future<ReadCursor?> advanceReadCursor(
    Uint8List groupId,
    Uri reader,
    InternalId messageId,
  ) async {
    final message = await getMessage(groupId, messageId);
    final current = await getReadCursor(groupId, reader);
    if (message == null || (current != null && current.covers(message))) {
      return null;
    }
    return cursors.putIfAbsent(
      base64Encode(groupId),
      () => {},
    )[reader] = ReadCursor(
      groupId: groupId,
      reader: reader,
      messageId: messageId,
      position: message.receivedAt,
    );
  }

  @override
  Future<void> moveMessages({
    required Uint8List from,
    required Uint8List to,
  }) async {
    final moved = cursors.remove(base64Encode(from)) ?? {};
    final kept = cursors.putIfAbsent(base64Encode(to), () => {});
    for (final cursor in moved.values) {
      final other = kept[cursor.reader];
      if (other != null && !cursor.position.isAfter(other.position)) continue;
      kept[cursor.reader] = ReadCursor(
        groupId: to,
        reader: cursor.reader,
        messageId: cursor.messageId,
        position: cursor.position,
      );
    }
    for (final (i, m) in messages.indexed.toList()) {
      if (!bytesEqual(m.groupId, from)) continue;
      messages[i] = _copy(m, groupId: to);
    }
    for (final (i, r) in reactions.indexed.toList()) {
      if (!bytesEqual(r.groupId, from)) continue;
      reactions[i] = StoredReaction(
        id: r.id,
        messageId: r.messageId,
        groupId: to,
        senderId: r.senderId,
        emoji: r.emoji,
        receivedAt: r.receivedAt,
      );
    }
  }

  StoredMessage _copy(
    StoredMessage m, {
    Uint8List? groupId,
    bool? delivered,
    Object? content = _keep,
    DateTime? editedAt,
    bool deleted = false,
  }) => StoredMessage(
    serverActivityId: m.serverActivityId,
    receivedAt: m.receivedAt,
    senderId: m.senderId,
    id: m.id,
    content: content == _keep ? m.content : content as String?,
    inReplyTo: m.inReplyTo,
    attachment: deleted ? const [] : m.attachment,
    groupId: groupId ?? m.groupId,
    delivered: delivered ?? m.delivered,
    editedAt: editedAt ?? m.editedAt,
    deleted: deleted || m.deleted,
  );
}

// [_MessageStore._copy] keeps the content unless it's given
const _keep = Object();

class _ProcessedObjectStore implements ProcessedObjectStore {
  final _ids = <Uri>{};

  @override
  Future<void> add(Uri id) async => _ids.add(id);

  @override
  Future<bool> check(Uri id) async => _ids.contains(id);

  @override
  // like the app, the first delivered for an object counts
  Future<bool> markDelivered(Uri id) async => _ids.add(id);
}

class _ApprovalRequestStore implements ApprovalRequestStore {
  final requests = <StoredApprovalRequest>[];

  @override
  Future<void> saveApprovalRequest(StoredApprovalRequest request) async =>
      requests.add(request);
}

bool bytesEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class _DeviceChainStore implements DeviceChainStore {
  final heads = <Uri, Uint8List>{};

  @override
  Future<Uint8List?> getPinnedHead(Uri actor) async => heads[actor];

  @override
  Future<void> pinHead(Uri actor, Uint8List head) async => heads[actor] = head;
}
