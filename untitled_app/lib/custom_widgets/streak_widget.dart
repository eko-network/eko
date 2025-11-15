import 'package:flutter/material.dart';

class StreakWidget extends StatelessWidget {
  const StreakWidget({
    super.key,
    required this.username,
    required this.streakDays,
    this.isTopStreak = false,
  });

  final String username;
  final int streakDays;
  final bool isTopStreak;

  // Emoji ladder function
  String getEmojiForStreak(int days) {
    if (days >= 100) return '🐉';
    if (days >= 50) return '🚀';
    if (days >= 40) return '💎';
    if (days >= 30) return '🧨';
    if (days >= 20) return '⚡️';
    if (days >= 10) return '🔥';
    return '✨';
  }

  @override
  Widget build(BuildContext context) {
    final emoji = getEmojiForStreak(streakDays);
    final crown = isTopStreak ? '👑 ' : '';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$crown$username ',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }
}