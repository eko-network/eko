import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/custom_widgets/time_stamp.dart';
import 'package:untitled_app/providers/activity_provider.dart';
import 'package:untitled_app/providers/user_provider.dart';
import 'package:untitled_app/types/user.dart';
import 'package:untitled_app/widgets/profile_picture.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/widgets/shimmer_loaders.dart';
import '../utilities/constants.dart' as c;

Widget recentActivityCardBuilder(String id) {
  return ActivityCardWidget(id: id);
}

class ActivityCardWidget extends ConsumerWidget {
  final String id;
  const ActivityCardWidget({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    final asyncActivity = ref.watch(activityProvider(id));

    return asyncActivity.when(
        data: (activity) {
          final bool hasUser = activity.sourceUid != null;
          return InkWell(
            onTap: () {
              if (activity.type == 'comment' || activity.type == 'tag') {
                context.push('/feed/post/${activity.path}');
              } else if (activity.type == 'follow') {
                context.push('/feed/sub_profile/${activity.path}');
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: height * 0.01),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.03, right: width * 0.015),
                    child: hasUser
                        ? ProfilePicture(
                            uid: activity.sourceUid!, size: width * 0.115)
                        : Container(
                            alignment: Alignment.center,
                            height: width * 0.14,
                            width: width * 0.14,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant),
                            child: Icon(
                              Icons.comment,
                              size: width * 0.08,
                            ),
                          ),
                  ),
                  Column(children: [
                    SizedBox(
                        width: width * 0.8,
                        child: activity.type == 'follow'
                            ? Text(
                                '${hasUser ? _username(ref.watch(userProvider(activity.sourceUid!)), AppLocalizations.of(context)!.someone) : AppLocalizations.of(context)!.someone} ${AppLocalizations.of(context)!.followText}',
                                softWrap: true,
                              )
                            : activity.type == 'tag'
                                ? Text(
                                    '${hasUser ? _username(ref.watch(userProvider(activity.sourceUid!)), AppLocalizations.of(context)!.someone) : AppLocalizations.of(context)!.someone} ${AppLocalizations.of(context)!.taggedText} ${activity.content}',
                                    softWrap: true,
                                  )
                                : Text(
                                    '${hasUser ? _username(ref.watch(userProvider(activity.sourceUid!)), AppLocalizations.of(context)!.someone) : AppLocalizations.of(context)!.someone} ${AppLocalizations.of(context)!.commentText}${activity.content.isEmpty ? '' : ': ${activity.content}'}',
                                    softWrap: true,
                                  )),
                    Container(
                      width: width * 0.8,
                      alignment: Alignment.centerLeft,
                      child: TimeStamp(
                        time: activity.createdAt,
                        fontSize: 12,
                      ),
                    ),
                  ])
                ],
              ),
            ),
          );
        },
        error: (_, __) => Text('error'),
        loading: () => UserLoader());
  }
}

String _username(AsyncValue<UserModel> asyncUser, String someone) {
  return asyncUser.when(
      data: (user) => '@${user.username}',
      error: (_, __) => someone,
      loading: () => someone);
}
