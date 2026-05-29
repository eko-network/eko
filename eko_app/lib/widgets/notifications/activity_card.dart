import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eko_app/widgets/common/time_stamp.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/providers/post_provider.dart';
import 'package:eko_app/providers/comment_provider.dart';
import 'package:eko_app/types/user.dart';
import 'package:eko_app/types/activity.dart';
import 'package:eko_app/widgets/users/profile_picture.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/utilities/constants.dart' as c;

Widget recentActivityCardBuilder(ActivityModel activity) {
  return ActivityCardWidget(activity: activity);
}

class ActivityCardWidget extends ConsumerWidget {
  final ActivityModel activity;
  const ActivityCardWidget({super.key, required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    final l10n = AppLocalizations.of(context)!;
    final asyncUser = ref.watch(userProvider(activity.sourceUid));

    return InkWell(
      onTap: () {
        switch (activity.type) {
          case ActivityType.follow:
            context.push('/users/_?uid=${activity.sourceUid}');
            break;
          case ActivityType.comment:
          case ActivityType.postTag:
          case ActivityType.commentTag:
          case ActivityType.eko:
            final postId = activity.postId;
            if (postId != null) {
              context.push('/feed/post/$postId');
            }
            break;
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: height * 0.01),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: width * 0.03,
                right: width * 0.015,
              ),
              child: ProfilePicture(
                uid: activity.sourceUid,
                size: width * 0.115,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          '${_username(asyncUser, l10n.someone)} ${_activityTypeText(activity.type, l10n)}',
                          softWrap: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TimeStamp(time: activity.dateTime),
                    ],
                  ),
                  _ActivityBody(activity: activity),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityBody extends ConsumerWidget {
  final ActivityModel activity;
  const _ActivityBody({required this.activity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? text = switch (activity.type) {
      ActivityType.follow => null,
      ActivityType.comment || ActivityType.commentTag =>
        activity.commentId == null
            ? null
            : ref
                  .watch(commentProvider(activity.commentId!))
                  .whenOrNull(data: (c) => c.body),
      ActivityType.postTag || ActivityType.eko =>
        activity.postId == null
            ? null
            : ref
                  .watch(postProvider(activity.postId!))
                  .whenOrNull(data: (p) => p.title ?? p.body),
    };

    if (text == null || text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}

String _username(AsyncValue<UserModel> asyncUser, String someone) {
  return asyncUser.when(
    data: (user) => user.username,
    error: (_, __) => someone,
    loading: () => someone,
  );
}

String _activityTypeText(ActivityType type, AppLocalizations l10n) {
  switch (type) {
    case ActivityType.follow:
      return l10n.followText;
    case ActivityType.postTag:
      return l10n.postTaggedText;
    case ActivityType.commentTag:
      return l10n.commentTaggedText;
    case ActivityType.comment:
      return l10n.commentText;
    case ActivityType.eko:
      return l10n.ekoText;
  }
}
