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

extension MlsEngineConfigRowMapper on MlsEngineConfigRow {
  MlsEngineConfig toConfig() {
    return MlsEngineConfig(dbPath: dbPath, encryptionKey: encryptionKey);
  }
}
