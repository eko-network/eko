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

Future<String> _getUdid() async {
  return kIsWeb ? _getWebUdid() : await FlutterUdid.udid;
}

@riverpod
class Presence extends _$Presence with WidgetsBindingObserver {
  DatabaseReference? _onlineRef;
  StreamSubscription<DatabaseEvent>? _statusSubscription;
  Timer? _periodicUpdate;
  AppLifecycleListener? _appLifecycleListener;
  bool _isActive = true;

  @override
  OnlineStatus build() {
    // uid will be null if the auth hasn't finished. build will get recalled if auth changes
    final uid = ref.watch(authProvider).uid;

    _init(uid);

    AppLifecycleListener(
      onResume: () {
        //gaurd becuase this can fire twice
        if (_isActive) return;
        _isActive = true;
        // re initialize
        final uid = ref.watch(authProvider).uid;
        _init(uid);
      },
      onPause: () {
        if (!_isActive) return;
        _isActive = false;

        // set offline if the lead device
        if (state.valid) {
          _onlineRef?.update({'online': false});
        }

        // dispose
        _statusSubscription?.cancel();
        _periodicUpdate?.cancel();
        _statusSubscription = null;
        _periodicUpdate = null;
      },
    );

    ref.onDispose(() {
      // these get killed here and on background
      _onlineRef?.remove();
      _statusSubscription?.cancel();
      _periodicUpdate?.cancel();
      // this should always be running
      _appLifecycleListener?.dispose();
    });
    // set to false while we figure out device status
    return const OnlineStatus(online: false, id: '', lastChanged: 0);
  }

  void _init(String? uid) async {
    if (uid == null) return;

    //null aware assignment to avoid creating two timers on accident.
    _periodicUpdate ??= Timer.periodic(
        const Duration(minutes: 8), (_) => maybeUpdateTimestamp());

    _onlineRef ??= FirebaseDatabase.instance.ref('status/$uid');

    final udid = await _getUdid();
    _statusSubscription = _onlineRef!.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null) {
        final jsonData = Map<String, dynamic>.from(data as Map);
        final status = OnlineStatus.fromJson(jsonData);
        final valid = status.id == udid;
        // if offline we need to set to online and take the lead
        if (!status.online) validateSession();
        // if online don't interfere with current device
        state = state.copyWith(
          online: status.online,
          lastChanged: status.lastChanged,
          valid: valid,
        );
      } else {
        // if there is no entry we need to create one the write will trigger an update
        // which will update state in the other side of this condition.
        validateSession();
      }
    });

    // set offline on disconnect
    await _onlineRef!.onDisconnect().update({'online': false});
  }

  Future<void> validateSession() async {
    final uid = ref.read(authProvider).uid;
    if (uid == null) return;
    final deviceUid = await _getUdid();
    // set to online with current device as lead
    await FirebaseDatabase.instance.ref('status/$uid').set({
      'online': true,
      'id': deviceUid,
      'last_changed': ServerValue.timestamp,
    });
  }

  void maybeUpdateTimestamp() {
    final uid = ref.read(authProvider).uid;
    if (state.valid && uid != null) {
      _onlineRef?.update({'last_changed': ServerValue.timestamp});
    }
  }
}
