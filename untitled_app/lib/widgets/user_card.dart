import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/user_provider.dart';
import 'package:untitled_app/types/user.dart';
import 'package:untitled_app/widgets/profile_picture.dart';
import 'package:untitled_app/widgets/shimmer_loaders.dart';
import '../utilities/constants.dart' as c;

Widget userCardBuilder(String uid) {
  return UserCard(
    uid: uid,
  );
}

class FollowButton extends ConsumerWidget {
  final UserModel user;
  const FollowButton({super.key, required this.user});

  Future<void> onFollowPressed(WidgetRef ref, UserModel user) async {
    await ref.read(UserProvider(user.uid).notifier).toggleFollow();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
    final currentUser = ref.watch(currentUserProvider);
    if (user.uid == currentUser.uid) {
      return SizedBox();
    }
    return InkWell(
      onTap: () => onFollowPressed(ref, user),
      child: Container(
        width: width * 0.25,
        height: width * 0.08,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: user.isFollowing
              ? Theme.of(context).colorScheme.outlineVariant
              : Theme.of(context).colorScheme.primaryContainer,
        ),
        child: Text(
          user.isFollowing
              ? AppLocalizations.of(context)!.following
              : AppLocalizations.of(context)!.follow,
          maxLines: 1,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

//action widget will default to follow and onCardPressed will defualt to go to profile. to overide this explicitly pass a value such as SizedBox or (){}
class UserCard extends ConsumerWidget {
  final bool showBlockedUsers;
  final Widget Function(UserModel)? actionWidget;
  final String uid;
  final void Function(UserModel)? onCardPressed;
  const UserCard({
    super.key,
    required this.uid,
    this.actionWidget,
    this.showBlockedUsers = false,
    this.onCardPressed,
  });

  // void unblockPressed(UserModel user) {
  //   ref.read(currentUserProvider.notifier).unBlockUser(uid);
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    final userAsync = ref.watch(userProvider(uid));

    return userAsync.when(
      data: (user) {
        final currentUser = ref.watch(currentUserProvider);
        //FIXME
        // if (!showBlockedUsers &&
        //     (currentUser.blockedUsers.contains(user.uid) ||
        //         currentUser.blockedBy.contains(user.uid))) {
        //   return SizedBox.shrink();
        // }
        return InkWell(
          onTap: () {
            if (onCardPressed != null) {
              onCardPressed!(user);
            } else {
              context.push('/feed/sub_profile/${user.uid}');
            }
          },
          child: Padding(
            padding:
                EdgeInsets.symmetric(vertical: height * 0.01, horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ProfilePicture(
                      uid: user.uid,
                      size: width * 0.115,
                    ),
                    Padding(
                      padding: EdgeInsets.all(width * 0.02),
                      child: SizedBox(
                        width: width * 0.5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (user.name.isNotEmpty)
                              Row(
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (user.isVerified)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Icon(
                                        Icons.verified_rounded,
                                        size: c.verifiedIconSize,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceTint,
                                      ),
                                    ),
                                ],
                              ),
                            Text('@${user.username}',
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (actionWidget != null)
                  actionWidget!(user)
                else
                  FollowButton(user: user)
              ],
            ),
          ),
        );
      },
      error: (err, _) => Text('Oops $err'),
      loading: () => const UserLoader(),
    );
  }
}
