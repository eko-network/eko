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
      );

  List<StoredMessage> get messages => (messageStore as _MessageStore).messages;
  List<MlsGroupRecord> get groups => (groupStore as _GroupStore).groups;
  List<StoredApprovalRequest> get approvalRequests =>
      (approvalRequestStore as _ApprovalRequestStore).requests;

  @override
  Future<void> clear() async {
    messages.clear();
    groups.clear();
    approvalRequests.clear();
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

  @override
  Future<void> saveGroup({
    required Uint8List groupIdBytes,
    String? displayName,
  }) async {
    if (await getGroupByGroupId(groupIdBytes) != null) return;
    groups.add(
      MlsGroupRecord(
        id: groups.length + 1,
        groupIdBytes: groupIdBytes,
        displayName: displayName,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<MlsGroupRecord?> getGroup(int id) async =>
      groups.where((g) => g.id == id).firstOrNull;

  @override
  Future<MlsGroupRecord?> getGroupByGroupId(Uint8List groupIdBytes) async =>
      groups.where((g) => bytesEqual(g.groupIdBytes, groupIdBytes)).firstOrNull;

  @override
  Future<List<MlsGroupRecord>> getActiveGroups() async =>
      groups.where((g) => g.isActive).toList();
}

class _MessageStore implements MessageStore {
  final messages = <StoredMessage>[];

  @override
  Future<void> saveMessage(StoredMessage message) async =>
      messages.add(message);

  @override
  Future<bool> markMessageDelivered(Uri serverActivityId) async =>
      messages.any((m) => m.serverActivityId == serverActivityId);
}

class _ProcessedObjectStore implements ProcessedObjectStore {
  final _ids = <Uri>{};

  @override
  Future<void> add(Uri id) async => _ids.add(id);

  @override
  Future<bool> check(Uri id) async => _ids.contains(id);

  @override
  Future<bool> markDelivered(Uri id) async => _ids.contains(id);
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
