import 'package:firebase_database/firebase_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/types/online_status.dart';

part '../generated/providers/online_provider.g.dart';

@riverpod
class Online extends _$Online {
  @override
  OnlineStatus build(String id) {
    _init(id);
    return const OnlineStatus(online: false, lastChanged: 0);
  }

  void _init(String id) {
    DatabaseReference onlineRef = FirebaseDatabase.instance.ref('status/$id');
    onlineRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null) {
        final jsonData = Map<String, dynamic>.from(data as Map);
        state = OnlineStatus.fromJson(jsonData);
      }
    });
  }
}
