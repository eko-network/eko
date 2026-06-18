import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../generated/messenger/providers/time_provider.g.dart';

@riverpod
class CurrentTime extends _$CurrentTime {
  Timer? _initialTimer;
  Timer? _periodicTimer;

  @override
  DateTime build() {
    ref.onDispose(() {
      _initialTimer?.cancel();
      _periodicTimer?.cancel();
    });

    final now = DateTime.now();

    final secondsUntilNextMinute = 60 - now.second;

    _initialTimer = Timer(Duration(seconds: secondsUntilNextMinute), () {
      state = DateTime.now();
      _periodicTimer = Timer.periodic(const Duration(minutes: 1), (_) {
        state = DateTime.now();
      });
    });

    return now;
  }
}
