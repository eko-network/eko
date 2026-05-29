import 'package:flutter_riverpod/flutter_riverpod.dart';

final conversationsProvider = StreamProvider.autoDispose<List<dynamic>>((ref) {
  return Stream.value([]);
});
