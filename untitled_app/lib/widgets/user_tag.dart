import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/providers/user_provider.dart';
import 'package:untitled_app/types/user.dart';
import 'package:untitled_app/widgets/verification_badge.dart';

class UserTag extends ConsumerWidget {
  final void Function()? onPressed;
  final void Function(UserModel)? onPressedWithUser;
  final TextStyle? style;
  final String uid;
  const UserTag(
      {required this.uid,
      this.style,
      this.onPressed,
      this.onPressedWithUser,
      super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(userProvider(uid));

    return asyncUser.when(
      data: (user) {
        return InkWell(
          onTap: onPressed ??
              (onPressedWithUser != null
                  ? () => onPressedWithUser!(user)
                  : null),
          child: Row(
            children: [
              Text(
                '@${user.username}',
                style: style ??
                    TextStyle(
                      fontSize: 17,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
              if (user.isVerified)
                VerificationBadge(
                  uid: user.uid,
                )
            ],
          ),
        );
      },
      error: (_, __) {
        return const Text('Error');
      },
      loading: () => const Text('Loading...'),
    );
  }
}
