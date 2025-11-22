import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatTime(DateTime time) {
  DateTime now = DateTime.now();
  Duration difference = now.difference(time);

  if (difference.inMinutes < 1) {
    return 'now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d';
  } else {
    return DateFormat('dd/MM/yy').format(now);
  }
}

class TimeStamp extends StatelessWidget {
  final DateTime time;
  final double fontSize;
  const TimeStamp({super.key, required this.time, this.fontSize = 15});

  @override
  Widget build(BuildContext context) {
    return Text(
      formatTime(time),
      style: TextStyle(
          fontSize: fontSize,
          color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}
