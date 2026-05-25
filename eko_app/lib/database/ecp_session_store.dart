import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ecp/ecp.dart';
import 'package:eko_app/database/database.dart';
import 'package:eko_app/types/ecp_session.dart';

class EcpSessionStore {
  EcpSessionStore(this._db);

  final AppDatabase _db;

  Future<EcpSession?> load() async {
    final row = await (_db.select(_db.authInfoTable)).getSingleOrNull();
    if (row == null) return null;
    final actorMap = jsonDecode(row.actorJson) as Map<String, dynamic>;
    return EcpSession(
      did: row.did,
      accessToken: row.accessToken,
      refreshToken: row.refreshToken,
      expiresAt: row.expiresAt,
      serverUrl: row.serverUrl,
      actor: Person.fromJson(actorMap),
    );
  }

  Future<void> save(EcpSession session) async {
    await _db.into(_db.authInfoTable).insertOnConflictUpdate(
          AuthInfoTableCompanion(
            id: const Value(1),
            did: Value(session.did),
            accessToken: Value(session.accessToken),
            refreshToken: Value(session.refreshToken),
            expiresAt: Value(session.expiresAt),
            actorJson: Value(jsonEncode(session.actor.toJson())),
            serverUrl: Value(session.serverUrl),
          ),
        );
  }

  Future<void> clear() async {
    await _db.delete(_db.authInfoTable).go();
  }
}
