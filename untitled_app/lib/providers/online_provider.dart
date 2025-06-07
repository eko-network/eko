import 'package:firebase_database/firebase_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/auth_provider.dart';
import 'package:untitled_app/types/online_status.dart';
import 'package:flutter_udid/flutter_udid.dart';

part '../generated/providers/online_provider.g.dart';

@riverpod
class Online extends _$Online {
  @override
  OnlineStatus build(String id) {
    _init(id);
    return const OnlineStatus(
        online: false, valid: false, id: '', lastChanged: 0);
  }

  void _init(String id) async {
    DatabaseReference onlineRef = FirebaseDatabase.instance.ref('status/$id');
    String deviceUid = await FlutterUdid.udid;
    onlineRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null) {
        final jsonData = Map<String, dynamic>.from(data as Map);
        OnlineStatus status = OnlineStatus.fromJson(jsonData);
        bool valid = status.online && (status.id == deviceUid);
        state = state.copyWith(
            online: status.online,
            lastChanged: status.lastChanged,
            valid: valid);
      }
    });
  }

  Future<void> validateSession() async {
    final uid = ref.read(authProvider).uid!;
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('status/$uid');
    Map<String, dynamic> isOnlineForDatabase = {
      'online': true,
      'id': 'blah',
      'last_changed': ServerValue.timestamp,
    };
    await dbRef.set(isOnlineForDatabase);
  }
}
