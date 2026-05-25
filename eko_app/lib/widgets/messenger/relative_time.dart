import 'package:eko_app/providers/messenger_time_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class RelativeTimeWidget extends ConsumerWidget {
  final DateTime time;
  final TextStyle? style;
  const RelativeTimeWidget({super.key, required this.time, this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(currentTimeProvider);
    final dif = now.difference(time);
    final String text;
    if (dif.inMinutes < 1) {
      text = 'now';
    } else if (dif.inHours < 1) {
      text = '${dif.inMinutes}m';
    } else {
      text = DateFormat.jm().format(time);
    }
    return Text(
      text,
      style:
          style ?? const TextStyle(fontSize: 10, fontWeight: FontWeight.w300),
    );
  }
}
