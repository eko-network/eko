import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../generated/messenger/providers/time_provider.g.dart';

@riverpod
DateTime currentTime(Ref ref) {
  final timer = Timer(const Duration(minutes: 1), () {
    ref.invalidateSelf();
  });

  ref.onDispose(() {
    timer.cancel();
  });

  return DateTime.now();
}
