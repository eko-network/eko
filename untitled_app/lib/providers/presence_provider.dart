import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/auth_provider.dart';
import 'package:untitled_app/types/online_status.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:untitled_app/utilities/shared_pref_service.dart';
import 'package:uuid/uuid.dart';
part '../generated/providers/presence_provider.g.dart';

String _getWebUdid() {
  final fromPref = PrefsService.instance.getString('web_udid_presence');
  if (fromPref == null) {
    final uid = Uuid().v4();
    PrefsService.instance.setString('web_udid_presence', uid);
    return uid;
  }
  return fromPref;
}

@riverpod
class Presence extends _$Presence with WidgetsBindingObserver {
  DatabaseReference? _onlineRef;
  StreamSubscription<DatabaseEvent>? _statusSubscription;
  Timer? _setTimer;

  final _uuid = _getWebUdid();

  @override
  OnlineStatus build() {
    WidgetsBinding.instance.addObserver(this);
    _init();
    ref.onDispose(() {
      _onlineRef?.remove();
      _statusSubscription?.cancel();
      _setTimer?.cancel();
    });
    return const OnlineStatus(online: false, id: '', lastChanged: 0);
  }

  void _init() async {
    await setOnline();
    _setTimer = Timer.periodic(
        const Duration(minutes: 10), (_) => maybeUpdateTimestamp());

    final uid = ref.read(authProvider).uid!;
    final deviceUid = kIsWeb ? _uuid : await FlutterUdid.udid;
    _onlineRef = FirebaseDatabase.instance.ref('status/$uid');

    _statusSubscription = _onlineRef!.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null) {
        final jsonData = Map<String, dynamic>.from(data as Map);
        final status = OnlineStatus.fromJson(jsonData);
        final valid = status.id == deviceUid;

        if (!status.online) validateSession();
        state = state.copyWith(
          online: status.online,
          lastChanged: status.lastChanged,
          valid: valid,
        );
      }
    });

    // set offline on disconnect
    await _onlineRef!.onDisconnect().update({'online': false});
  }

  Future<void> setOnline() async {
    final uid = ref.read(authProvider).uid!;
    final dbRef = FirebaseDatabase.instance.ref('status/$uid');

    final deviceUid = kIsWeb ? _uuid : await FlutterUdid.udid;

    final snapshot = await dbRef.get();
    final onlineData = {
      'online': true,
      'last_changed': ServerValue.timestamp,
    };

    if (snapshot.exists) {
      final jsonData = Map<String, dynamic>.from(snapshot.value as Map);
      final status = OnlineStatus.fromJson(jsonData);

      if (!status.online && status.id != deviceUid) {
        onlineData['id'] = deviceUid;
      }
    }

    await dbRef.update(onlineData);
  }

  Future<void> validateSession() async {
    final uid = ref.read(authProvider).uid!;
    final deviceUid = kIsWeb ? _uuid : await FlutterUdid.udid;
    await FirebaseDatabase.instance.ref('status/$uid').set({
      'online': true,
      'id': deviceUid,
      'last_changed': ServerValue.timestamp,
    });
  }

  Future<void> maybeUpdateTimestamp() async {
    final uid = ref.read(authProvider).uid!;
    if (state.valid) {
      await FirebaseDatabase.instance
          .ref('status/$uid')
          .update({'last_changed': ServerValue.timestamp});
    }
  }

  @override
  // make sure the disconnect to firebase is not dirty when app goes to foreground
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_onlineRef == null) return;

    if (state == AppLifecycleState.paused) {
      // app going to background
      _onlineRef!.update({'online': false});
      _statusSubscription?.cancel();
      _statusSubscription = null;
    } else if (state == AppLifecycleState.resumed) {
      _init();
    }
  }
}
