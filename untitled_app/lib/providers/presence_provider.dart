import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/auth_provider.dart';
import 'package:untitled_app/types/online_status.dart';
import 'package:flutter_udid/flutter_udid.dart';

part '../generated/providers/presence_provider.g.dart';

@riverpod
class Presence extends _$Presence with WidgetsBindingObserver {
  DatabaseReference? _onlineRef;
  StreamSubscription<DatabaseEvent>? _statusSubscription;

  @override
  OnlineStatus build() {
    WidgetsBinding.instance.addObserver(this);
    _init();
    ref.onDispose(() => _onlineRef?.remove());
    ref.onDispose(() => _statusSubscription?.cancel());
    return const OnlineStatus(online: false, id: '', lastChanged: 0);
  }

  void _init() async {
    await setOnline();

    final uid = ref.read(authProvider).uid!;
    final deviceUid = await FlutterUdid.udid;

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
    final deviceUid = await FlutterUdid.udid;

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
    final deviceUid = await FlutterUdid.udid;

    await FirebaseDatabase.instance.ref('status/$uid').set({
      'online': true,
      'id': deviceUid,
      'last_changed': ServerValue.timestamp,
    });
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
