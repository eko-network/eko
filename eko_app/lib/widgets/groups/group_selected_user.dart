import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/widgets/users/profile_picture.dart';

class SelectedUser extends ConsumerWidget {
  final String uid;
  final void Function(String) onPressed;
  final bool selected;
  const SelectedUser({
    super.key,
    required this.uid,
    required this.onPressed,
    required this.selected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(userProvider(uid));
    return InkWell(
      onTap: () => onPressed(uid),
      child: Container(
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            children: [
              ProfilePicture(uid: uid, size: 22),
              const SizedBox(width: 5),
              Text(
                asyncUser.when(
                  data: (user) =>
                      user.name.isNotEmpty ? user.name : user.username,
                  error: (_, _) => '',
                  loading: () => '',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
