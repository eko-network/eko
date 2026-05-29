import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  final bool isReceived;
  final dynamic messageWithAttachments;
  final dynamic position;

  const MessageWidget({
    super.key,
    required this.isReceived,
    required this.messageWithAttachments,
    this.position,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class DateChip extends StatelessWidget {
  final DateTime time;
  const DateChip({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
