import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ecp/ecp.dart';
import 'package:eko_app/messenger/providers/group_provider.dart';
import 'package:eko_app/messenger/ecp_helpers.dart';
import 'package:eko_app/providers/ecp_provider.dart';
import 'package:eko_app/services/messenger_notification_service.dart';
import 'package:eko_app/utilities/ecp_db_path.dart';
import 'package:eko_app/utilities/platform.dart' as platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
part '../generated/messenger/notification_service_share.g.dart';

/// What the iOS notification service (MessengerNotificationService) needs to
/// fetch the inbox, send delivered acks and title what it shows, while the
/// app is not running.
@Riverpod(keepAlive: true)
void notificationServiceShare(Ref ref) {
  if (!platform.isIOS) return;
  ref.listen(asyncEcpClientProvider, (_, next) {
    if (next.hasValue) unawaited(NotificationServiceShare.save(next.value!));
  }, fireImmediately: true);
  // the groups change with every message, the names only with which they are
  var saved = '';
  ref.listen(groupProvider, (_, next) {
    final groups = next.value;
    if (groups == null) return;
    final ids = (groups.map((g) => g.id).toList()..sort()).join(',');
    if (ids == saved) return;
    saved = ids;
    unawaited(
      NotificationServiceShare.saveNames(ref.read(ecpClientProvider), groups),
    );
  }, fireImmediately: true);
}

abstract final class NotificationServiceShare {
  static const _keychain = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
      groupId: 'group.com.example.untitledApp',
    ),
  );
  static const _configKey = 'messenger_notification_service';
  static const _namesFile = 'notification_names.json';

  /// A token is minted every time, which also replaces one the server lost.
  static Future<void> save(EcpClient client) async {
    try {
      final token = await client.mintNotificationToken();
      final me = client.me;
      await _keychain.write(
        key: _configKey,
        value: jsonEncode({
          'actor': me.id.toString(),
          'inbox': me.inbox.toString(),
          'outbox': me.outbox.toString(),
          'token': token,
        }),
      );
    } catch (e) {
      // it shows a generic notification until the next start
      debugPrint('[NotificationServiceShare] save failed: $e');
    }
  }

  /// Only active groups are listed, the service shows no content for others,
  /// e.g. one hidden until a contact's reset is accepted.
  static Future<void> saveNames(
    EcpClient client,
    List<MlsGroupRecord> groups,
  ) async {
    try {
      final members = <String>{};
      for (final group in groups) {
        final gm = await client.groups.getMembers(group);
        members.addAll(gm.members.map((m) => m.uid()));
      }
      final users = <String, String>{};
      for (final uid in members) {
        final username = await MessengerNotificationService.username(uid);
        if (username != null) users[uid] = username;
      }
      final file = File(p.join(await getDbPath(), _namesFile));
      await file.writeAsString(
        jsonEncode({
          'groups': {
            for (final group in groups)
              base64Url.encode(group.groupIdBytes).replaceAll('=', ''):
                  '${group.id}',
          },
          'users': users,
        }),
        flush: true,
      );
    } catch (e) {
      debugPrint('[NotificationServiceShare] names failed: $e');
    }
  }

  static Future<void> clear() async {
    if (!platform.isIOS) return;
    try {
      await _keychain.delete(key: _configKey);
      final file = File(p.join(await getDbPath(), _namesFile));
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('[NotificationServiceShare] clear failed: $e');
    }
  }
}
