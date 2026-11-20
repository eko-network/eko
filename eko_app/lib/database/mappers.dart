import 'package:ecp/ecp.dart';
import 'database.dart';

extension MlsCredentialRowMapper on MlsCredentialRow {
  MlsCredentialRecord toRecord() {
    return MlsCredentialRecord(
      credentialIdentity: credentialIdentity,
      credentialBytes: credentialBytes,
      signerBytes: signerBytes,
      signerPublicKey: signerPublicKey,
    );
  }
}

extension MlsGroupRowMapper on MlsGroupRow {
  MlsGroupRecord toRecord() {
    return MlsGroupRecord(
      id: id,
      groupIdBytes: groupIdBytes,
      displayName: displayName,
      createdAt: createdAt,
      lastActivityAt: lastActivityAt,
      isActive: isActive,
    );
  }
}

extension StoredMessageRowMapper on StoredMessageRow {
  StoredMessage toMessage([List<ActivityPubObject> attachment = const []]) {
    return StoredMessage(
      content: content,
      serverActivityId: serverActivityId,
      receivedAt: receivedAt,
      senderId: senderId,
      id: id,
      inReplyTo: inReplyTo,
      attachment: attachment,
      groupId: groupId,
      delivered: delivered,
      editedAt: editedAt,
      deleted: deleted,
    );
  }
}

extension MessageReactionRowMapper on MessageReactionRow {
  StoredReaction toReaction() {
    return StoredReaction(
      id: id,
      messageId: messageId,
      groupId: groupId,
      senderId: senderId,
      emoji: emoji,
      receivedAt: receivedAt,
    );
  }
}

extension ReadCursorRowMapper on ReadCursorRow {
  ReadCursor toCursor() {
    return ReadCursor(
      groupId: groupId,
      reader: reader,
      messageId: messageId,
      position: position,
    );
  }
}

extension MlsEngineConfigRowMapper on MlsEngineConfigRow {
  MlsEngineConfig toConfig() {
    return MlsEngineConfig(dbPath: dbPath, encryptionKey: encryptionKey);
  }
}
