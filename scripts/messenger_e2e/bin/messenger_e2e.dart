// Headless multi-device test of the messenger: device approval, own devices
// in chats, device removal and GIF messages, against local Supabase and a
// local eko-messenger server. Run through scripts/dev.sh e2e, or directly:
//
//   SUPABASE_URL=http://127.0.0.1:54321 SUPABASE_ANON_KEY=... \
//   SUPABASE_SERVICE_ROLE_KEY=... MESSENGER_URL=http://127.0.0.1:3000 \
//   dart run bin/messenger_e2e.dart
//
// Uses the seeded accounts from supabase/seed.sql.
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

  await step('a second device signs in pending', () async {
    await alice2.setUp();
    check(alice2.tokenDid == alice2.did, 'token should carry the did');
    check(!alice2.approved, 'alice-2 should not be approved');
  });

  await step('a pending device cannot approve itself', () async {
    await rejects(() => alice2.rpc('approve_device', {'did': alice2.did}));
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
    await alice1.rpc('approve_device', {'did': request.did});
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
    await alice1.sendText(group.groupId, 'hi carol');
    await receives(carol1, (m) => m.content == 'hi carol');
    await receives(alice2, (m) => m.content == 'hi carol');
  });

  await step('an approved device can remove another', () async {
    await alice1.rpc('remove_device', {'p_did': alice2.did});
    await alice1.client.groups.removeDeviceFromGroups(
      publicKey: alice2.credential.signerPublicKey,
    );
    final rows = await alice1.selectDevices();
    check(rows.every((r) => r['id'] != alice2.did), 'record should be gone');

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

  await step(
    'after the last device signs out, sign-in is trusted again',
    () async {
      await bob1.signOut();
      await bob2.setUp();
      check(bob2.approved, 'bob-2 should be trusted on first use');
    },
  );

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

/// Device records from earlier runs would make the first devices pending, so
/// the seeded users start from none, and are left with none afterwards.
Future<void> _removeTestDevices(Env env) async {
  final serviceKey = _env('SUPABASE_SERVICE_ROLE_KEY');
  final res = await http.delete(
    env.supabaseUrl.replace(
      path: '/rest/v1/devices',
      queryParameters: {
        'uid':
            'in.(a11ce000-0000-4000-8000-000000000001,'
            'b0b00000-0000-4000-8000-000000000002,'
            'ca201000-0000-4000-8000-000000000003)',
      },
    ),
    headers: {'apikey': serviceKey, 'Authorization': 'Bearer $serviceKey'},
  );
  if (res.statusCode >= 300) {
    stderr.writeln('could not clear test devices: ${res.body}');
    exit(2);
  }
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
