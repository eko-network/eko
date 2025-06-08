import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/user_provider.dart';
import 'package:untitled_app/types/online_status.dart';

part '../generated/providers/online_provider.g.dart';

@riverpod
class Online extends _$Online {
  StreamSubscription<DatabaseEvent>? _listener;
  @override
  OnlineStatus build(String id) {
    final user = ref.watch(userProvider(id));
    if (user.hasValue && user.value!.shareOnlineStatus) _init(id);
    ref.onDispose(() => _listener?.cancel());
    return const OnlineStatus(online: false, id: '', lastChanged: 0);
  }

  void _init(String id) async {
    if (_listener != null) {
      return;
    }
    DatabaseReference onlineRef = FirebaseDatabase.instance.ref('status/$id');
    _listener = onlineRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null) {
        final jsonData = Map<String, dynamic>.from(data as Map);
        OnlineStatus status = OnlineStatus.fromJson(jsonData);
        state = state.copyWith(
          online: status.online,
        );
      }
    });
  }
}
