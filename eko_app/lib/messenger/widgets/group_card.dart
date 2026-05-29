import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/messenger/types/group.dart';
import 'package:eko_app/messenger/widgets/relative_time.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/widgets/users/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _GroupTitle extends ConsumerWidget {
  final GroupWithUsers gu;
  final List<String> otherUsers;
  const _GroupTitle(this.gu, this.otherUsers);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDM = otherUsers.length == 1;
    final isNoteToSelf =
        gu.users.length == 1 &&
        gu.users.first == ref.watch(currentUserProvider).user.uid;
    assert(
      isNoteToSelf || otherUsers.isNotEmpty,
      'Cannot display a group with no members',
    );

    final l10n = AppLocalizations.of(context)!;
    final String title = isNoteToSelf
        ? l10n.noteToSelf
        : (!isDM && gu.group.displayName != null)
        ? gu.group.displayName!
        : ref
              .watch(
                userProvider(
                  otherUsers.isNotEmpty ? otherUsers.first : gu.users.first,
                ),
              )
              .when(
                data: (data) => data.username.isNotEmpty
                    ? '@${data.username}${isDM ? '' : ' + ${otherUsers.length - 1}'}'
                    : l10n.error,
                error: (_, _) => l10n.error,
                loading: () => l10n.loadingEllipsis,
              );

    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w500),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class GroupCard extends ConsumerWidget {
  final GroupWithUsers gu;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showOnlyAvatar;
  const GroupCard({
    super.key,
    required this.gu,
    required this.isSelected,
    required this.onTap,
    required this.showOnlyAvatar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myUid = ref.watch(currentUserProvider).user.uid;
    final otherUsers = gu.users.where((uid) => uid != myUid).toList();
    final displayUid = otherUsers.isNotEmpty
        ? otherUsers.first
        : gu.users.first;

    final width = c.widthGetter(context);
    // TODO make a better widget for this
    final pfp = ProfilePicture(uid: displayUid, size: width * 0.115);

    return ListTile(
      selected: isSelected,
      leading: showOnlyAvatar ? null : pfp,
      title: showOnlyAvatar ? pfp : _GroupTitle(gu, otherUsers),
      subtitle: showOnlyAvatar
          ? null
          : Text('group', maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: showOnlyAvatar
          ? null
          : RelativeTimeWidget(time: gu.group.lastActivityAt!),
      onTap: () => onTap(),
    );
  }
}
