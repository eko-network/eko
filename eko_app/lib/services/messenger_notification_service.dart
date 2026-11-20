import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:ecp/ecp.dart';
import 'package:eko_app/database/database.dart';
import 'package:eko_app/database/storage.dart';
import 'package:eko_app/interfaces/notification_helper.dart';
import 'package:eko_app/messenger/ecp_helpers.dart';
import 'package:eko_app/messenger/utilities/authenticated_http_client.dart';
import 'package:eko_app/utilities/platform.dart' as platform;
import 'package:eko_app/utilities/shared_pref_service.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

/// Messenger notifications for platforms that receive pushes through
/// UnifiedPush. Pushes only say that a message arrived, the inbox is fetched
/// and decrypted here. iOS decrypts in the MessengerNotificationService
/// extension instead.
class MessengerNotificationService {
  static const _mainPortName = 'eko_messenger_main';
  static const _mainPortTimeout = Duration(seconds: 2);
  // keeps message ids clear of the counter the post notifications use
  static const _notificationIdBase = 1 << 30;
  static const _channelId = 'eko_messages';
  static const _channelName = 'Messages';

  static ReceivePort? _mainPort;
  static Future<void> _headlessSync = Future.value();
  static final Map<String, String?> _usernames = {};

  static bool get _supported => platform.isAndroid || platform.isLinux;

  /// Called by the running app so pushes received by a headless UnifiedPush
  /// engine are synced here, and two isolates never use the MLS state at once.
  static void registerMainIsolate(Future<void> Function() sync) {
    if (!_supported) return;
    unregisterMainIsolate();
    final port = ReceivePort();
    port.listen((message) async {
      if (message is SendPort) message.send(true);
      try {
        await sync();
      } catch (e, st) {
        debugPrint('[MessengerNotifications] sync failed: $e\n$st');
      }
    });
    IsolateNameServer.removePortNameMapping(_mainPortName);
    IsolateNameServer.registerPortWithName(port.sendPort, _mainPortName);
    _mainPort = port;
  }

  static void unregisterMainIsolate() {
    final port = _mainPort;
    if (port == null) return;
    IsolateNameServer.removePortNameMapping(_mainPortName);
    port.close();
    _mainPort = null;
  }

  static Future<void> handlePush() async {
    if (!_supported) return;
    if (await _handOffToMainIsolate()) return;
    // one at a time, a failed sync must not block the next push
    _headlessSync = _headlessSync
        .then((_) => _syncHeadless())
        .catchError(
          (Object e) => debugPrint('[MessengerNotifications] sync error: $e'),
        );
    await _headlessSync;
  }

  /// The mapping outlives an isolate whose engine was destroyed, so the app
  /// has to answer before it counts as running.
  static Future<bool> _handOffToMainIsolate() async {
    final main = IsolateNameServer.lookupPortByName(_mainPortName);
    if (main == null) return false;
    final reply = ReceivePort();
    try {
      main.send(reply.sendPort);
      await reply.first.timeout(_mainPortTimeout);
      return true;
    } on TimeoutException {
      debugPrint('[MessengerNotifications] app did not answer, syncing here');
      IsolateNameServer.removePortNameMapping(_mainPortName);
      return false;
    } finally {
      reply.close();
    }
  }

  /// Runs [body] with Supabase, which the push engine only has while it
  /// syncs, so it is set up here then, one at a time with the syncs.
  static Future<void> withSupabase(Future<void> Function() body) {
    final run = _headlessSync
        .then((_) async {
          final own = !supabaseInitialized;
          if (own) await initSupabase(background: true);
          try {
            await body();
          } finally {
            if (own) await disposeSupabase();
          }
        })
        .catchError((Object e) => debugPrint('[MessengerNotifications] $e'));
    _headlessSync = run;
    return run;
  }

  static Future<void> _syncHeadless() async {
    EcpCore? core;
    http.Client? httpClient;
    try {
      await initSupabase(background: true);
      var session = supabase.auth.currentSession;
      if (session != null && session.isExpired) {
        session = (await supabase.auth.refreshSession()).session;
      }
      final did = PrefsService.deviceUid;
      if (session == null || did == null || did.isEmpty) return;

      final storage = AppStorage(db);
      // only use MLS state the app set up, never create it from a push
      final engineConfig = await storage.mlsEngineConfigStore.getConfig();
      if (engineConfig == null) return;

      core = EcpCore(
        storage: storage,
        identity: EkoPerson.fromUid(session.user.id),
        engineConfig: engineConfig,
      );
      httpClient = AuthenticatedClient(freshAccessToken);
      final client = await EcpClient.build(
        core: core,
        did: did,
        client: httpClient,
        tokenGetter: () async => await freshAccessToken() ?? '',
      );
      await showForMessages(await client.getInbox(), me: core.identity.id);
    } catch (e, st) {
      debugPrint('[MessengerNotifications] headless sync failed: $e\n$st');
    } finally {
      httpClient?.close();
      await core?.close();
      // stops token auto refresh so it can't race the app's own refresh
      await disposeSupabase();
    }
  }

  /// Shows one notification per group, unless the app is in the foreground.
  /// Of reactions only those to our own messages are shown.
  static Future<void> showForMessages(
    List<ReceivedEvent> events, {
    required Uri me,
  }) async {
    if (!_supported || events.isEmpty) return;
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      return;
    }

    for (final event in events) {
      try {
        switch (event) {
          case ReceivedMessage(:final message) when message.senderId != me:
            await _show(message.groupId, message.senderId, _preview(message));
          case ReceivedReaction(:final reaction, :final message)
              when reaction.senderId != me && message.senderId == me:
            await _show(
              message.groupId,
              reaction.senderId,
              'Reacted ${reaction.emoji} to: ${_preview(message)}',
            );
          case ReceivedMessage() || ReceivedReaction():
            break;
        }
      } catch (e, st) {
        debugPrint('[MessengerNotifications] show failed: $e\n$st');
      }
    }
  }

  static String _preview(StoredMessage message) {
    final content = message.content?.trim() ?? '';
    return content.isNotEmpty
        ? content
        : message.attachment.isNotEmpty
        ? 'Sent an attachment'
        : 'New message';
  }

  static Future<void> _show(
    Uint8List groupId,
    Uri senderId,
    String body,
  ) async {
    final group = await (db.select(
      db.mlsGroups,
    )..where((t) => t.groupIdBytes.equals(groupId))).getSingleOrNull();
    if (group == null || !group.isActive) return;

    final sender = await username(uidFromActorId(senderId));

    await NotificationHelper.showLocalNotification(
      id: _notificationIdBase + group.id,
      title: sender != null ? '@$sender' : 'New message',
      body: body,
      channelId: _channelId,
      channelName: _channelName,
      payload: jsonEncode({
        'data': {'type': 'message', 'path': '${group.id}'},
      }),
    );
  }

  static Future<String?> username(String uid) async {
    if (_usernames.containsKey(uid)) return _usernames[uid];
    try {
      final response = await supabase.rpc(
        'get_user_by_id',
        params: {'p_uid': uid},
      );
      final row = response is List && response.isNotEmpty
          ? response.first
          : null;
      final username = row is Map ? row['username'] as String? : null;
      final result = username == null || username.isEmpty ? null : username;
      _usernames[uid] = result;
      return result;
    } catch (e) {
      debugPrint('[MessengerNotifications] username lookup failed: $e');
      return null;
    }
  }
}
