// Headless multi-device test of the messenger: device approval, own devices
// in chats, device removal, GIF messages and the device chain holding up
// against a server or a group member that tries to add devices, against
// local Supabase and a local eko-messenger server. Run through
// scripts/dev.sh e2e, or directly:
//
//   SUPABASE_URL=http://127.0.0.1:54321 SUPABASE_ANON_KEY=... \
//   SUPABASE_SERVICE_ROLE_KEY=... MESSENGER_URL=http://127.0.0.1:3000 \
//   dart run bin/messenger_e2e.dart
//
// Uses the seeded accounts from supabase/seed.sql.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ecp/ecp.dart';
import 'package:http/http.dart' as http;
import 'package:messenger_e2e/device.dart';
import 'package:messenger_e2e/memory_storage.dart';

const _timeout = Duration(seconds: 15);
final _gifUrl = Uri.parse(
  'https://static.klipy.com/ii/4e7bea9f7a3371424e6d16ebc93252fe/e2e.gif',
);

var _failed = 0;
late final Env _runEnv;

Future<void> main() async {
  final env = _runEnv = Env(
    supabaseUrl: Uri.parse(_env('SUPABASE_URL', 'http://127.0.0.1:54321')),
    anonKey: _env('SUPABASE_ANON_KEY'),
    messengerUrl: Uri.parse(_env('MESSENGER_URL', 'http://127.0.0.1:3000')),
  );
  await _removeTestDevices(env);

  final alice1 = SimDevice(env, 'alice-1', 'alice@test.local');
  final alice2 = SimDevice(env, 'alice-2', 'alice@test.local');
  final bob1 = SimDevice(env, 'bob-1', 'bob@test.local');
  final bob2 = SimDevice(env, 'bob-2', 'bob@test.local');
  final carol1 = SimDevice(env, 'carol-1', 'carol@test.local');
  late Uint8List dm;
  late Uint8List carolChat;

  await step('first devices are trusted on first use', () async {
    for (final d in [alice1, bob1, carol1]) {
      await d.setUp();
      check(d.approved, '${d.name} should be approved');
    }
  });

  await step('alice-1 starts a chat with bob', () async {
    final (group, _) = await alice1.client.groups.createGroup([
      alice1.personFor(bob1.uid),
    ]);
    dm = group.groupId;
    await alice1.sendText(dm, 'hi bob');
    await receives(bob1, (m) => m.content == 'hi bob');
  });

  await step('starting the DM again, from either side, reuses it', () async {
    final (again, _) = await alice1.client.groups.createGroup([
      alice1.personFor(bob1.uid),
    ]);
    check(bytesEqual(again.groupId, dm), 'alice-1 started a second DM');
    final (fromBob, _) = await bob1.client.groups.createGroup([
      bob1.personFor(alice1.uid),
    ]);
    check(bytesEqual(fromBob.groupId, dm), 'bob-1 started a second DM');
  });

  await step('a second device signs in pending', () async {
    await alice2.setUp();
    check(alice2.tokenDid == alice2.did, 'token should carry the did');
    check(!alice2.approved, 'alice-2 should not be approved');
  });

  await step('a pending device cannot approve itself', () async {
    await rejects(
      () => alice2.rpc('approve_device', {
        'did': alice2.did,
        'p_entry': <String, dynamic>{},
        'p_hash': '',
      }),
    );
    final rows = await alice2.selectDevices();
    final row = rows.firstWhere((r) => r['id'] == alice2.did);
    check(row['approved_at'] == null, 'approved_at should still be null');
  });

  await step('a pending device cannot remove another device', () async {
    await rejects(() => alice2.rpc('remove_device', {'p_did': alice1.did}));
  });

  await step("a pending device's key packages are not handed out", () async {
    await rejects(
      () => bob1.rpc('take_key_package', {'p_device_id': alice2.did}),
    );
  });

  await step('a pending device receives no messages', () async {
    await bob1.sendText(dm, 'while pending');
    await receives(alice1, (m) => m.content == 'while pending');
    try {
      final got = await alice2.sync();
      check(got.isEmpty, 'alice-2 received ${got.length} message(s)');
    } on EcpNetworkException catch (e) {
      // the server refuses the inbox of an unapproved device outright
      check(e.statusCode == 403, 'unexpected inbox error: $e');
    }
  });

  await step('alice-1 gets the approval request and approves', () async {
    await until('approval request on alice-1', () async {
      await alice1.sync();
      return alice1.storage.approvalRequests.any((r) => r.did == alice2.did);
    });
    final request = alice1.storage.approvalRequests.firstWhere(
      (r) => r.did == alice2.did,
    );
    check(
      bytesEqual(request.publicKey, alice2.credential.signerPublicKey),
      'request key should be alice-2 signer key',
    );
    await alice1.approve(request.did, request.publicKey);
    await alice1.client.groups.addOwnDevice(
      did: request.did,
      publicKey: request.publicKey,
    );
    await alice2.refreshSession();
    check(alice2.approved, 'alice-2 should be approved after refresh');
  });

  await step('the approved device joins the existing chat', () async {
    await until('alice-2 joins the dm', () async {
      await alice2.sync();
      return alice2.storage.groups.any((g) => bytesEqual(g.groupIdBytes, dm));
    });
    // bob has to apply alice-1's add commit before sending in the new epoch
    await until('bob applies the add commit', () async {
      await bob1.sync();
      final indices = await bob1.core.memberIndicesForKey(
        dm,
        alice2.credential.signerPublicKey,
      );
      return indices.isNotEmpty;
    });
    await bob1.sendText(dm, 'to both of you');
    await receives(alice1, (m) => m.content == 'to both of you');
    await receives(alice2, (m) => m.content == 'to both of you');
  });

  await step("own messages reach the sender's other devices", () async {
    await alice1.sendText(dm, 'from alice-1');
    final msg = await receives(alice2, (m) => m.content == 'from alice-1');
    check(msg.senderId == alice1.person.id, 'sender should be alice');
    await receives(bob1, (m) => m.content == 'from alice-1');
    final echo = await alice1.sync();
    check(
      echo.every((m) => m.content != 'from alice-1'),
      'alice-1 got its own message back',
    );
  });

  await step('GIFs are delivered with their attachment', () async {
    final note = ActivityPubObject.newNote(
      attachments: [
        ActivityPubObject.newImage(
          url: _gifUrl,
          mediaType: 'image/gif',
          width: 220,
          height: 124,
        ),
      ],
    );
    await alice1.client.messages.sendMessage(
      Activity.newCreate(object: note),
      dm,
    );
    for (final d in [bob1, alice2]) {
      final msg = await receives(d, (m) => m.attachment.isNotEmpty);
      final image = msg.attachment.single;
      check(image is Image, '${d.name}: attachment should be an Image');
      if (image is Image) {
        check(image.url == _gifUrl, '${d.name}: url ${image.url}');
        check(image.width == 220 && image.height == 124, 'size lost');
      }
    }
  });

  await step('a bare Image activity is stored as an attachment', () async {
    await bob1.client.messages.sendMessage(
      Activity.newCreate(
        object: ActivityPubObject.newImage(
          url: _gifUrl,
          mediaType: 'image/gif',
        ),
      ),
      dm,
    );
    await receives(
      alice1,
      (m) => m.senderId == bob1.person.id && m.attachment.isNotEmpty,
    );
  });

  await step("new chats include the creator's other devices", () async {
    final (group, _) = await alice1.client.groups.createGroup([
      alice1.personFor(carol1.uid),
    ]);
    carolChat = group.groupId;
    await alice1.sendText(carolChat, 'hi carol');
    await receives(carol1, (m) => m.content == 'hi carol');
    await receives(alice2, (m) => m.content == 'hi carol');
  });

  await step('an approved device can remove another', () async {
    await alice1.removeDevice(alice2.did);
    await alice1.client.groups.removeDeviceFromGroups(
      publicKey: alice2.credential.signerPublicKey,
    );
    final rows = await alice1.selectDevices();
    check(rows.every((r) => r['id'] != alice2.did), 'record should be gone');
    final chain = await bob1.client.devices.fetch(bob1.personFor(alice1.uid));
    check(
      chain.devices.map((d) => d.did).join() == alice1.did,
      'alice-2 should be revoked in the chain',
    );

    await until('bob applies the remove commit', () async {
      await bob1.sync();
      final indices = await bob1.core.memberIndicesForKey(
        dm,
        alice2.credential.signerPublicKey,
      );
      return indices.isEmpty;
    });
    await bob1.sendText(dm, 'after removal');
    await receives(alice1, (m) => m.content == 'after removal');
    try {
      final got = await alice2.sync();
      check(
        got.every((m) => m.content != 'after removal'),
        'removed device still received messages',
      );
    } on EcpNetworkException {
      // the server refusing the removed device entirely is fine too
    }
  });

  // the service role key stands in for a malicious server: it can write any
  // row, but holds none of the users' device keys
  final carol = bob1.personFor(carol1.uid);
  final fake = await _fakeDevice(carol);

  await step('a device the server adds is not trusted', () async {
    await _service(
      'POST',
      'devices',
      body: {
        'id': fake.did,
        'uid': carol1.uid,
        'signer_public_key': _bytea(fake.credential.signerPublicKey),
        'approved_at': DateTime.now().toUtc().toIso8601String(),
      },
    );
    await _service(
      'POST',
      'key_packages',
      body: {'device_id': fake.did, 'key_package': _bytea(fake.keyPackage)},
    );
    final chain = await bob1.client.devices.fetch(carol);
    check(
      chain.devices.map((d) => d.did).join() == carol1.did,
      'only carol-1 should be trusted, got ${chain.devices.map((d) => d.did)}',
    );
    final (group, _) = await bob1.client.groups.createGroup([carol]);
    final members = await bob1.core.memberIndicesForKey(
      group.groupId,
      fake.credential.signerPublicKey,
    );
    check(members.isEmpty, 'the fake device was added to the chat');
    await bob1.sendText(group.groupId, 'only for carol');
    await receives(carol1, (m) => m.content == 'only for carol');
  });

  await step("commits need a claim on the group's current epoch", () async {
    final senders = alice1.client.messages.activitySender;
    final epoch = await alice1.core.engine.groupEpoch(groupIdBytes: carolChat);
    Future<void> commitTo(BigInt epoch) => _sendCommit(alice1, carolChat, [
      carol,
    ], _commitFraming(carolChat, epoch));

    await conflicts(() => commitTo(epoch));
    await carol1.client.messages.activitySender.claimEpoch(carolChat, epoch);
    await conflicts(() => senders.claimEpoch(carolChat, epoch));
    await carol1.client.messages.activitySender.releaseEpoch(carolChat);
    await senders.claimEpoch(carolChat, epoch);
    await conflicts(() => senders.claimEpoch(carolChat, epoch - BigInt.one));
    await conflicts(() => commitTo(epoch - BigInt.one));
    await senders.releaseEpoch(carolChat);
  });

  // alice-1 stands in for a malicious member: it can commit to its groups,
  // but has no say in other users' device chains
  await step("a device a member adds for someone else is removed", () async {
    final warnings = <GroupDeviceWarning>[];
    final sub = carol1.client.groups.deviceWarnings.listen(warnings.add);
    try {
      await alice1.client.messages.activitySender.claimEpoch(
        carolChat,
        await alice1.core.engine.groupEpoch(groupIdBytes: carolChat),
      );
      final result = await alice1.core.addMembers(carolChat, [fake.keyPackage]);
      await _sendCommit(alice1, carolChat, [carol], result.commit);
      // both remove the fake device at once, the server lets one commit
      // through and the other device catches up instead of splitting the
      // group
      await (
        until('carol-1 flags the fake device', () async {
          await carol1.sync();
          return warnings.isNotEmpty;
        }),
        alice1.client.groups.removeDeviceFromGroups(
          publicKey: fake.credential.signerPublicKey,
        ),
      ).wait;
      final warning = warnings.single;
      check(warning.owner == carol.id, 'owner ${warning.owner}');
      check(warning.addedBy == alice1.person.id, 'by ${warning.addedBy}');
      check(!warning.unverified, 'the fake device should be unknown');
      for (final d in [alice1, carol1]) {
        await _removedBy(d, carolChat, fake.credential.signerPublicKey);
      }
    } finally {
      await sub.cancel();
    }
    final epochs = await Future.wait([
      for (final d in [alice1, carol1])
        d.core.engine.groupEpoch(groupIdBytes: carolChat),
    ]);
    check(epochs[0] == epochs[1], 'the group split at epochs $epochs');
    await alice1.sendText(carolChat, 'after the fake device');
    await receives(carol1, (m) => m.content == 'after the fake device');
    await carol1.sendText(carolChat, 'carol after the fake device');
    await receives(alice1, (m) => m.content == 'carol after the fake device');
  });

  await step("a device in a member's welcome is removed", () async {
    final warnings = <GroupDeviceWarning>[];
    final sub = carol1.client.groups.deviceWarnings.listen(warnings.add);
    try {
      final group = await alice1.core.createGroup(null);
      final carolDevice = (await alice1.client.devices.fetch(
        carol,
      )).deviceFor(carol1.did)!;
      final carolKey = await alice1.client.devices.requestKey(
        carol,
        carolDevice,
      );
      final result = await alice1.core.addMembers(group.groupId, [
        carolKey.key,
        fake.keyPackage,
      ]);
      await alice1.client.groups.sendWelcomes([carol], result);
      await until('carol-1 joins and flags the fake device', () async {
        await carol1.sync();
        return warnings.isNotEmpty;
      });
      check(
        warnings.single.addedBy == alice1.person.id,
        'by ${warnings.single.addedBy}',
      );
      await _removedBy(alice1, group.groupId, fake.credential.signerPublicKey);
    } finally {
      await sub.cancel();
    }
  });

  await step('a chain entry the server forges is rejected', () async {
    final rows =
        await _service(
              'GET',
              'device_chain',
              query: {'uid': 'eq.${carol1.uid}', 'order': 'seq'},
            )
            as List;
    final last = rows.last as Map<String, dynamic>;
    final forged = await _forgedAdd(
      carol,
      fake,
      signer: carol1.did,
      prev: _unbytea(last['hash'] as String),
    );
    await _service(
      'POST',
      'device_chain',
      body: {
        'uid': carol1.uid,
        'seq': (last['seq'] as int) + 1,
        'entry': forged.toJson(),
        'hash': _bytea(forged.hash),
      },
    );
    try {
      await bob1.client.devices.fetch(carol);
      throw _CheckFailed('the forged chain was accepted');
    } on EcpDeviceChainException {
      // expected
    } finally {
      await _service(
        'DELETE',
        'device_chain',
        query: {
          'uid': 'eq.${carol1.uid}',
          'seq': 'eq.${(last['seq'] as int) + 1}',
        },
      );
    }
  });

  await step("a key package for another key is rejected", () async {
    await _service(
      'DELETE',
      'key_packages',
      query: {'device_id': 'eq.${carol1.did}'},
    );
    await _service(
      'POST',
      'key_packages',
      body: {'device_id': carol1.did, 'key_package': _bytea(fake.keyPackage)},
    );
    final device = (await bob1.client.devices.fetch(
      carol,
    )).deviceFor(carol1.did)!;
    try {
      await bob1.client.devices.requestKey(carol, device);
      throw _CheckFailed('the swapped key package was accepted');
    } on EcpDeviceChainException {
      // expected
    }
  });

  await step('a chain the server replaces is noticed', () async {
    await _service(
      'DELETE',
      'device_chain',
      query: {'uid': 'eq.${carol1.uid}'},
    );
    final genesis = await DeviceChainEntry.genesis(
      actor: carol.id,
      did: fake.did,
      credential: fake.credential,
    );
    await _service(
      'POST',
      'device_chain',
      body: {
        'uid': carol1.uid,
        'seq': 0,
        'entry': genesis.toJson(),
        'hash': _bytea(genesis.hash),
      },
    );
    try {
      await bob1.client.devices.fetch(carol);
      throw _CheckFailed('the replaced chain was accepted');
    } on EcpDeviceChainChangedException catch (e) {
      check(e.actor == carol.id, 'wrong actor ${e.actor}');
    }
  });

  await step(
    'after the last device signs out, sign-in is trusted again',
    () async {
      await bob1.signOut();
      await bob2.setUp();
      check(bob2.approved, 'bob-2 should be trusted on first use');
    },
  );

  await step("a chat with a reset contact warns and keeps them", () async {
    final warnings = <GroupDeviceWarning>[];
    final sub = alice1.client.groups.deviceWarnings.listen(warnings.add);
    try {
      await alice1.client.groups.verifyGroup(dm);
      await until('alice-1 warns', () async => warnings.isNotEmpty);
      check(warnings.single.unverified, 'the chain change should be flagged');
      final indices = await alice1.core.memberIndicesForKey(
        dm,
        bob1.credential.signerPublicKey,
      );
      check(indices.isNotEmpty, "bob-1 shouldn't be removed before accepting");
    } finally {
      await sub.cancel();
    }
  });

  await step("contacts notice the reset and can accept it", () async {
    final bob = alice1.personFor(bob2.uid);
    try {
      await alice1.client.devices.fetch(bob);
      throw _CheckFailed('the reset chain was accepted silently');
    } on EcpDeviceChainChangedException {
      // expected
    }
    final chain = await alice1.client.devices.trust(bob);
    check(
      chain.devices.map((d) => d.did).join() == bob2.did,
      'the new chain should list bob-2',
    );
    await alice1.client.devices.fetch(bob);
  });

  await step("once accepted, the contact's old devices leave chats", () async {
    await alice1.client.groups.verifyGroup(dm);
    final indices = await alice1.core.memberIndicesForKey(
      dm,
      bob1.credential.signerPublicKey,
    );
    check(indices.isEmpty, 'bob-1 should be removed from the dm');
  });

  for (final d in [alice1, alice2, bob2, carol1]) {
    await d.close().catchError((_) {});
  }
  stdout.writeln(_failed == 0 ? '\nall steps passed' : '\n$_failed failed');
  // leftover approved devices would leave real app windows for these
  // accounts pending with nothing able to approve them
  await _removeTestDevices(env);
  exit(_failed == 0 ? 0 : 1);
}

String _env(String key, [String? fallback]) {
  final value = Platform.environment[key] ?? fallback;
  if (value == null || value.isEmpty) {
    stderr.writeln('$key is not set');
    exit(2);
  }
  return value;
}

/// Device records and chains from earlier runs would make the first devices
/// pending, so the seeded users start from none, and are left with none
/// afterwards.
Future<void> _removeTestDevices(Env env) async {
  const uids =
      'in.(a11ce000-0000-4000-8000-000000000001,'
      'b0b00000-0000-4000-8000-000000000002,'
      'ca201000-0000-4000-8000-000000000003)';
  try {
    await _service('DELETE', 'devices', query: {'uid': uids});
    await _service('DELETE', 'device_chain', query: {'uid': uids});
  } on RpcException catch (e) {
    stderr.writeln('could not clear test devices: $e');
    exit(2);
  }
}

/// A PostgREST request with the service role, which bypasses row level
/// security like the server's own database access does.
Future<dynamic> _service(
  String method,
  String table, {
  Map<String, String>? query,
  Object? body,
}) async {
  final serviceKey = _env('SUPABASE_SERVICE_ROLE_KEY');
  final request = http.Request(
    method,
    _runEnv.supabaseUrl.replace(
      path: '/rest/v1/$table',
      queryParameters: query,
    ),
  );
  request.headers.addAll({
    'apikey': serviceKey,
    'Authorization': 'Bearer $serviceKey',
    'Content-Type': 'application/json',
  });
  if (body != null) request.body = jsonEncode(body);
  final res = await http.Response.fromStream(await request.send());
  if (res.statusCode >= 300) throw RpcException(res.statusCode, res.body);
  return res.body.isEmpty ? null : jsonDecode(res.body);
}

/// Sends a commit [device] already merged, bypassing the checks
/// [GroupManager] does before committing.
Future<void> _sendCommit(
  SimDevice device,
  Uint8List groupId,
  List<Person> to,
  Uint8List commit,
) async {
  final ids = to.map((p) => p.id).toList();
  await device.client.messages.activitySender.sendActivity(
    WireCreate(
      actor: device.person.id,
      to: ids,
      object: PrivateMessage(actor: device.person.id, to: ids, content: commit),
    ),
  );
}

/// The unencrypted framing of an MLS private message carrying a commit to
/// [epoch] of [groupId], all the server reads of one.
Uint8List _commitFraming(Uint8List groupId, BigInt epoch) {
  final epochBytes = ByteData(8)..setUint64(0, epoch.toInt());
  return Uint8List.fromList([
    0, 1, 0, 2, // mls10, private message
    groupId.length, ...groupId, // a one byte size prefix, ids are short
    ...epochBytes.buffer.asUint8List(),
    3, // commit
    0, 0, 0, // authenticated data, sender data, ciphertext
  ]);
}

/// Waits for [device] to apply a commit removing [signatureKey]'s leaves.
Future<void> _removedBy(
  SimDevice device,
  Uint8List groupId,
  Uint8List signatureKey,
) => until('${device.name} applies the removal', () async {
  await device.sync();
  return (await device.core.memberIndicesForKey(groupId, signatureKey)).isEmpty;
});

String _bytea(List<int> bytes) =>
    '\\x${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';

Uint8List _unbytea(String value) {
  final hex = value.substring(2);
  return Uint8List.fromList([
    for (var i = 0; i < hex.length; i += 2)
      int.parse(hex.substring(i, i + 2), radix: 16),
  ]);
}

/// A device the server makes up for [person]: a key pair and a key package
/// that name the person, but no approval from any of their devices.
Future<({String did, MlsCredentialRecord credential, Uint8List keyPackage})>
_fakeDevice(Person person) async {
  final signer = MlsSignatureKeyPair.generate(
    ciphersuite: MlsCiphersuite.mls128DhkemX25519Aes128GcmSha256Ed25519,
  );
  final identity = Uint8List.fromList(utf8.encode(person.id.toString()));
  final credential = MlsCredentialRecord(
    credentialIdentity: identity,
    credentialBytes: MlsCredential.basic(identity: identity).serialize(),
    signerBytes: serializeSigner(
      ciphersuite: MlsCiphersuite.mls128DhkemX25519Aes128GcmSha256Ed25519,
      privateKey: signer.privateKey(),
      publicKey: signer.publicKey(),
    ),
    signerPublicKey: signer.publicKey(),
  );
  final engine = await MlsEngine.create(
    dbPath: ':memory:',
    encryptionKey: Uint8List(32),
  );
  final keyPackage = await engine.createKeyPackage(
    ciphersuite: MlsCiphersuite.mls128DhkemX25519Aes128GcmSha256Ed25519,
    signerBytes: credential.signerBytes,
    credentialIdentity: credential.credentialIdentity,
    signerPublicKey: credential.signerPublicKey,
    credentialBytes: credential.credentialBytes,
  );
  return (
    did: '00000000-0000-4000-8000-00000000fa4e',
    credential: credential,
    keyPackage: keyPackage.keyPackageBytes,
  );
}

/// An AddDevice entry for [fake] that claims to be signed by [signer] but is
/// signed with the fake device's own key, the best the server can do.
Future<DeviceChainEntry> _forgedAdd(
  Person person,
  ({String did, MlsCredentialRecord credential, Uint8List keyPackage}) fake, {
  required String signer,
  required Uint8List prev,
}) async {
  // sign a genuine entry with the fake key, then relabel signer and prev
  final selfSigned = await DeviceChainEntry.genesis(
    actor: person.id,
    did: fake.did,
    credential: fake.credential,
  );
  final json = selfSigned.toJson()
    ..['signer'] = signer
    ..['prev'] = base64Encode(prev);
  return DeviceChainEntry.fromJson(json);
}

class _CheckFailed implements Exception {
  final String message;
  _CheckFailed(this.message);
  @override
  String toString() => message;
}

/// Runs a step; later steps depend on earlier ones, so the first failure ends
/// the run.
Future<void> step(String name, Future<void> Function() body) async {
  try {
    await body();
    stdout.writeln('ok    $name');
  } catch (e, st) {
    _failed++;
    stdout.writeln('FAIL  $name\n      $e');
    if (e is! _CheckFailed) stdout.writeln(st);
    await _removeTestDevices(_runEnv);
    exit(1);
  }
}

void check(bool condition, String message) {
  if (!condition) throw _CheckFailed(message);
}

Future<void> rejects(Future<dynamic> Function() call) async {
  try {
    await call();
  } on RpcException {
    return;
  }
  throw _CheckFailed('expected the call to be rejected');
}

Future<void> conflicts(Future<void> Function() call) async {
  try {
    await call();
  } on EcpEpochConflictException {
    return;
  }
  throw _CheckFailed('expected an epoch conflict');
}

Future<void> until(String what, Future<bool> Function() condition) async {
  final deadline = DateTime.now().add(_timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (await condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
  throw _CheckFailed('timed out waiting for $what');
}

/// Syncs [device] until a stored message matches.
Future<StoredMessage> receives(
  SimDevice device,
  bool Function(StoredMessage) match,
) async {
  StoredMessage? found;
  await until('${device.name} to receive a message', () async {
    await device.sync();
    found = device.storage.messages.where(match).lastOrNull;
    return found != null;
  });
  return found!;
}
