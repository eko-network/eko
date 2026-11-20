import 'package:ecp/ecp.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/messenger/providers/group_provider.dart';
import 'package:eko_app/messenger/providers/message_provider.dart';
import 'package:eko_app/messenger/widgets/relative_time.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/widgets/loading/profile_picture_loading.dart';
import 'package:eko_app/widgets/users/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part '../../generated/messenger/widgets/group_card.g.dart';

/// Whether the group with row id [groupId] is a DM or a note to self, its
/// members other than us, and whose picture it shows.
@riverpod
Future<(bool, bool, Set<String>, String)> groupMeta(
  Ref ref,
  int groupId,
) async {
  final users = await ref.watch(groupMembersProvider(groupId).future);
  final myUid = ref.watch(currentUserProvider).user.uid;
  final otherUsers = users.where((uid) => uid != myUid).toSet();
  final isDm = otherUsers.length == 1;
  final isNoteToSelf = users.length == 1 && users.first == myUid;
  assert(
    isNoteToSelf || otherUsers.isNotEmpty,
    'Cannot display a group with no members',
  );
  return (isDm, isNoteToSelf, otherUsers, otherUsers.firstOrNull ?? myUid);
}

const _maxTitleUsernames = 10;

class GroupTitle extends ConsumerWidget {
  final MlsGroupRecord group;
  const GroupTitle({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final String title = ref
        .watch(groupMetaProvider(group.id))
        .when(
          data: (meta) {
            final (isDm, isNoteToSelf, otherUsers, _) = meta;
            if (isNoteToSelf) return l10n.noteToSelf;
            if (!isDm && group.displayName != null) return group.displayName!;
            // each username is its own request, so only fetch the first few
            final shown = otherUsers.take(_maxTitleUsernames).toList();
            final users = [
              for (final uid in shown) ref.watch(userProvider(uid)),
            ];
            if (users.any((u) => u.isLoading)) return l10n.loadingEllipsis;
            final names = [
              for (final u in users)
                if (u.value?.username.isNotEmpty ?? false)
                  '@${u.value!.username}',
            ];
            if (names.isEmpty) return l10n.error;
            return otherUsers.length > shown.length
                ? '${names.join(', ')}, …'
                : names.join(', ');
          },
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
  final MlsGroupRecord group;
  const GroupIcon({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayUid = ref.watch(groupMetaProvider(group.id)).value?.$4;
    if (displayUid == null) return ClipOval(child: LoadingProfileImage());
    return ProfilePicture(uid: displayUid);
  }
}

class GroupSubtitle extends ConsumerWidget {
  final MlsGroupRecord group;
  const GroupSubtitle({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final last = ref.watch(lastMessageProvider(group.id)).value;
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

/// When the group last had activity, and how many messages are unread.
class GroupTrailing extends ConsumerWidget {
  final MlsGroupRecord group;
  const GroupTrailing({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider(group.id)).value ?? 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        RelativeTimeWidget(time: group.lastActivityAt!),
        if (unread > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Badge.count(
              count: unread,
              backgroundColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
      ],
    );
  }
}

class GroupCard extends ConsumerWidget {
  final MlsGroupRecord group;
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
    final unread = showOnlyAvatar
        ? ref.watch(unreadCountProvider(group.id)).value ?? 0
        : 0;

    return ListTile(
      selected: isSelected,
      leading: showOnlyAvatar ? null : pfp,
      title: showOnlyAvatar
          // the count is next to the time otherwise
          ? Badge.count(
              count: unread,
              isLabelVisible: unread > 0,
              backgroundColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
              child: pfp,
            )
          : GroupTitle(group: group),
      subtitle: showOnlyAvatar ? null : GroupSubtitle(group: group),
      trailing: showOnlyAvatar ? null : GroupTrailing(group: group),
      onTap: () => onTap(),
    );
  }
}
