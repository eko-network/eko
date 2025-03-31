import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/models/current_user.dart';
import '../models/group_handler.dart';
import '../custom_widgets/time_stamp.dart';
import '../utilities/constants.dart' as c;
import '../utilities/locator.dart';
import 'package:provider/provider.dart';
import '../controllers/groups_page_controller.dart';

Widget groupCardBuilder(dynamic group) {
  return GroupCard(
    group: group,
  );
}

class GroupCard extends StatelessWidget {
  final Group group;
  final void Function(Group)? onPressedSearched;
  const GroupCard({super.key, required this.group, this.onPressedSearched});

  @override
  Widget build(BuildContext context) {
    final double width = c.widthGetter(context);
    String currentUserId = locator<CurrentUser>().uid;
    bool unseen = group.notSeen.contains(currentUserId);

    return InkWell(
        onTap: () async {
          if (onPressedSearched == null) {
            context.push("/groups/sub_group/${group.id}", extra: group).then(
                (value) => unseen
                    ? Provider.of<GroupsPageController>(context, listen: false)
                        .rebuild()
                    : null);
            await locator<CurrentUser>().setUnreadGroup(false);
          } else {
            //if in compose page
            onPressedSearched!(group);
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: width * 0.05,
                  ),
                  (group.icon != '')
                      ? SizedBox(
                          width: width * 0.17,
                          height: width * 0.17,
                          child: FittedBox(
                              fit: BoxFit.contain,
                              child: Text(group.icon,
                                  style: TextStyle(fontSize: width * 0.15))),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          width: width * 0.17,
                          height: width * 0.17,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              group.name[0],
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: width * 0.15),
                            ),
                          ),
                        ),
                  SizedBox(
                    width: width * 0.05,
                  ),
                  SizedBox(
                      width: width * 0.45,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.name,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: unseen
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            Text(
                              group.description,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: unseen
                                      ? FontWeight.bold
                                      : FontWeight.w300),
                            ),
                          ])),

                  // RichText(
                  //   text: TextSpan(
                  //     style: TextStyle(fontSize: 19),
                  //     text: group.name,
                  //     children: [
                  //       TextSpan(
                  //           style: TextStyle(fontSize: 15),
                  //           text: "\n${group.description}"),
                  //     ],
                  //   ),
                  // ),
                  const Spacer(),
                  unseen
                      ? const Icon(
                          Icons.circle,
                          size: 10,
                          color: Color(0xFF0095f6),
                        )
                      : Container(),
                  SizedBox(
                    width: width * 0.02,
                  ),
                  if (onPressedSearched == null)
                    TimeStamp(
                      time: group.lastActivity,
                    ),
                  SizedBox(
                    width: width * 0.05,
                  ),
                ],
              ),
            ),
            Divider(
              color: Theme.of(context).colorScheme.outline,
              height: c.dividerWidth,
            ),
          ],
        ));
  }
}
