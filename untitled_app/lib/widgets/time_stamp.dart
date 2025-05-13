import 'package:flutter/material.dart';

String formatTime(DateTime time) {
  DateTime now = DateTime.now();
  Duration difference = now.difference(time);

  int totalMonths = 0;
  totalMonths = (now.year - time.year) * 12;
  totalMonths += now.month - time.month;

  if (now.day < time.day) {
    totalMonths--;
  }
  int years = totalMonths ~/ 12;
  int days = difference.inDays;

  if (totalMonths >= 12) {
    return '${years}y';
  } else if (totalMonths > 0) {
    return '${totalMonths}mo';
  } else if (days > 0) {
    return '${days}d';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}h';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m';
  } else {
    return 'now';
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
