import 'package:flutter/material.dart';
import 'package:untitled_app/custom_widgets/time_stamp.dart';
import '../models/post_handler.dart' show RecentActivityCard;
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../custom_widgets/profile_avatar.dart';
import '../utilities/constants.dart' as c;

Widget recentActivityCardBuilder(dynamic data) {
  return ActivityCardWidget(card: data);
}

class ActivityCardWidget extends StatelessWidget {
  final RecentActivityCard card;
  const ActivityCardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    final bool hasUser = card.sourceUser != null;
    return InkWell(
      onTap: () {
        if (card.type == "comment" || card.type == "tag") {
          context.push("/feed/post/${card.path}");
        } else if (card.type == "follow") {
          context.push("/feed/sub_profile/${card.path}");
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: height * 0.01),
        child: Row(
          children: [
            Padding(
              padding:
                  EdgeInsets.only(left: width * 0.03, right: width * 0.015),
              child: hasUser
                  ? ProfileAvatar(
                      url: card.sourceUser!.profilePicture, size: width * 0.115)
                  : Container(
                      alignment: Alignment.center,
                      height: width * 0.14,
                      width: width * 0.14,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.outlineVariant),
                      child: Icon(
                        Icons.comment,
                        size: width * 0.08,
                      ),
                    ),
            ),
            Column(children: [
              SizedBox(
                  width: width * 0.8,
                  child: card.type == "follow"
                      ? Text(
                          "${(hasUser && card.sourceUser!.username != "") ? "@${card.sourceUser!.username}" : AppLocalizations.of(context)!.someone} ${AppLocalizations.of(context)!.followText}",
                          softWrap: true,
                        )
                      : card.type == "tag"
                          ? Text(
                              "${(hasUser && card.sourceUser!.username != "") ? "@${card.sourceUser!.username}" : AppLocalizations.of(context)!.someone} ${AppLocalizations.of(context)!.taggedText} ${card.content}",
                              softWrap: true,
                            )
                          : Text(
                              "${(hasUser && card.sourceUser!.username != "") ? "@${card.sourceUser!.username}" : AppLocalizations.of(context)!.someone} ${AppLocalizations.of(context)!.commentText} ${card.content}",
                              softWrap: true,
                            )),
              Container(
                width: width * 0.8,
                alignment: Alignment.centerLeft,
                child: TimeStamp(
                  time: card.time,
                  fontSize: 12,
                ),
              ),
            ])
          ],
        ),
      ),
    );
  }
}
