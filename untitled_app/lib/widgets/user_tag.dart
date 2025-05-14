import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/providers/user_provider.dart';
import 'package:untitled_app/utilities/constants.dart' as c;

class UserTag extends ConsumerWidget {
  final void Function()? onPressed;
  final TextStyle? style;
  final String uid;
  const UserTag({required this.uid, this.style, this.onPressed, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(userProvider(uid));

    return asyncUser.when(
      data: (user) {
        return InkWell(
          onTap: onPressed,
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
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.verified_rounded,
                    size: c.verifiedIconSize,
                    color: Theme.of(context).colorScheme.surfaceTint,
                  ),
                ),
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
