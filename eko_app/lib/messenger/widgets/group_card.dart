import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/messenger/providers/message_provider.dart';
import 'package:eko_app/messenger/types/group.dart';
import 'package:eko_app/messenger/widgets/relative_time.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/widgets/users/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part '../../generated/messenger/widgets/group_card.g.dart';

@riverpod
(bool, bool, Set<String>) groupMeta(Ref ref, GroupWithUsers group) {
  final myUid = ref.watch(currentUserProvider).user.uid;
  final otherUsers = group.users.where((uid) => uid != myUid).toSet();
  final isDm = otherUsers.length == 1;
  final isNoteToSelf =
      group.users.length == 1 &&
      group.users.first == ref.watch(currentUserProvider).user.uid;
  return (isDm, isNoteToSelf, otherUsers);
}

class GroupTitle extends ConsumerWidget {
  final GroupWithUsers group;
  const GroupTitle({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (isDm, isNoteToSelf, otherUsers) = ref.watch(
      groupMetaProvider(group),
    );
    assert(
      isNoteToSelf || otherUsers.isNotEmpty,
      'Cannot display a group with no members',
    );

    final l10n = AppLocalizations.of(context)!;
    final String title = isNoteToSelf
        ? l10n.noteToSelf
        : (!isDm && group.group.displayName != null)
        ? group.group.displayName!
        : ref
              .watch(
                userProvider(
                  otherUsers.isNotEmpty ? otherUsers.first : group.users.first,
                ),
              )
              .when(
                data: (data) => data.username.isNotEmpty
                    ? '@${data.username}${isDm ? '' : ' + ${otherUsers.length - 1}'}'
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

class GroupIcon extends ConsumerWidget {
  final GroupWithUsers group;
  const GroupIcon({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (isDm, isNoteToSelf, otherUsers) = ref.watch(
      groupMetaProvider(group),
    );
    assert(
      isNoteToSelf || otherUsers.isNotEmpty,
      'Cannot display a group with no members',
    );
    final displayUid = otherUsers.isNotEmpty
        ? otherUsers.first
        : group.users.first;

    return ProfilePicture(uid: displayUid);
  }
}

class GroupSubtitle extends ConsumerWidget {
  final GroupWithUsers group;
  const GroupSubtitle({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final last = ref.watch(lastMessageProvider(group.group.groupIdBytes)).value;
    final content = last?.content?.trim() ?? '';
    final text = last == null
        ? l10n.noMessagesYet
        : last.deleted
        ? l10n.messageDeleted
        : content.isNotEmpty
        // one line in the list, so line breaks become spaces
        ? content.replaceAll(RegExp(r'\s+'), ' ')
        : last.hasAttachment
        ? l10n.sentAnAttachment
        : '';

    return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}

class GroupCard extends ConsumerWidget {
  final GroupWithUsers group;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showOnlyAvatar;
  const GroupCard({
    super.key,
    required this.group,
    required this.isSelected,
    required this.onTap,
    required this.showOnlyAvatar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pfp = GroupIcon(group: group);

    return ListTile(
      selected: isSelected,
      leading: showOnlyAvatar ? null : pfp,
      title: showOnlyAvatar ? pfp : GroupTitle(group: group),
      subtitle: showOnlyAvatar ? null : GroupSubtitle(group: group),
      trailing: showOnlyAvatar
          ? null
          : RelativeTimeWidget(time: group.group.lastActivityAt!),
      onTap: () => onTap(),
    );
  }
}
