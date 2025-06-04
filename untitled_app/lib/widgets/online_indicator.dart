import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/online_provider.dart';

class OnlineIndicator extends ConsumerWidget {
  final String uid;
  final int? size;

  const OnlineIndicator({
    super.key,
    required this.uid,
    this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(onlineProvider(uid));
    final currentUser = ref.watch(currentUserProvider);

    if (online.online && uid != currentUser.user.uid) {
      return Align(
        alignment: Alignment.bottomRight,
        child: Container(
          width: (size ?? 40) * 0.25,
          height: (size ?? 40) * 0.25,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
