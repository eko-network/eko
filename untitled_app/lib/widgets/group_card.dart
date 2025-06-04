import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/group_provider.dart';
import '../custom_widgets/time_stamp.dart';
import '../utilities/constants.dart' as c;

Widget groupCardBuilder(String groupId) {
  return GroupCard(
    groupId: groupId,
  );
}

class GroupCard extends ConsumerWidget {
  final String groupId;
  final void Function(String)? onPressed;
  const GroupCard({super.key, required this.groupId, this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double width = c.widthGetter(context);
    final group = ref.watch(groupProvider(groupId));
    final uid = ref.read(currentUserProvider).user.uid;
    bool unseen = group.when(
        data: (data) => (data.notSeen.contains(uid)),
        error: (_, __) => false,
        loading: () => false);
    return group.when(
        data: (group) => InkWell(
              onTap: () async {
                if (onPressed == null) {
                  context.push('/groups/sub_group/$groupId', extra: group);
                  if (unseen) {
                    ref
                        .read(currentUserProvider.notifier)
                        .setUnreadGroup(false);
                    ref
                        .read(groupProvider(groupId).notifier)
                        .toggleUnread(false);
                  }
                } else {
                  //if in compose page
                  onPressed!(groupId);
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
                                        style:
                                            TextStyle(fontSize: width * 0.15))),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                ),
                                width: width * 0.17,
                                height: width * 0.17,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    group.name[0],
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
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
                        if (onPressed == null)
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
              ),
            ),
        error: (a, b) => SizedBox(),
        loading: () => SizedBox());
  }
}
