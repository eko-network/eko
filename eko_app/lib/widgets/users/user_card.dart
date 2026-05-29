import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/types/user.dart';
import 'package:eko_app/widgets/users/profile_picture.dart';
import 'package:eko_app/widgets/loading/shimmer_loaders.dart';
import 'package:eko_app/widgets/users/verification_badge.dart';
import 'package:eko_app/utilities/constants.dart' as c;

Widget userCardBuilder(String uid) {
  return UserCard(uid: uid);
}

class FollowButton extends ConsumerWidget {
  final UserModel user;
  const FollowButton({super.key, required this.user});

  Future<void> onFollowPressed(WidgetRef ref) async {
    await ref.read(userProvider(user.uid).notifier).toggleFollow();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
    final buttonWidth = (width * 0.22).clamp(92.0, 120.0).toDouble();
    final buttonHeight = (width * 0.07).clamp(34.0, 40.0).toDouble();
    final currentUser = ref.watch(currentUserProvider);
    final userState = ref.watch(userProvider(user.uid));
    final isFollowing = userState.value?.isFollowing ?? user.isFollowing;
    if (user.uid == currentUser.user.uid) {
      return SizedBox();
    }
    return InkWell(
      onTap: () => onFollowPressed(ref),
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: isFollowing
              ? Theme.of(context).colorScheme.outlineVariant
              : Theme.of(context).colorScheme.primaryContainer,
        ),
        child: Text(
          isFollowing
              ? AppLocalizations.of(context)!.following
              : AppLocalizations.of(context)!.follow,
          maxLines: 1,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
  final void Function(UserModel)? onCardTapDown;
  final bool canRequestFocus;
  const UserCard({
    super.key,
    required this.uid,
    this.actionWidget,
    this.showBlockedUsers = false,
    this.onCardPressed,
    this.onCardTapDown,
    this.canRequestFocus = true,
  });

  // void unblockPressed(UserModel user) {
  //   ref.read(currentUserProvider.notifier).unBlockUser(uid);
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.sizeOf(context).height;
    final userAsync = ref.watch(userProvider(uid));

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return userAsync.when(
          data: (user) {
            return InkWell(
              canRequestFocus: canRequestFocus,
              onTapDown: onCardTapDown == null
                  ? null
                  : (_) => onCardTapDown!(user),
              onTap: () {
                if (onCardPressed != null) {
                  onCardPressed!(user);
                } else {
                  context.push('/users/${user.username}?uid=${user.uid}');
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: height * 0.01,
                  horizontal: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ProfilePicture(uid: user.uid, size: width * 0.115),
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
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (user.isVerified)
                                        VerificationBadge(uid: uid),
                                    ],
                                  ),
                                Text(
                                  '@${user.username}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (actionWidget != null)
                      actionWidget!(user)
                    else
                      FollowButton(user: user),
                  ],
                ),
              ),
            );
          },
          error: (err, _) {
            debugPrint(err.toString());
            return Text(AppLocalizations.of(context)!.defaultErrorTitle);
          },
          loading: () => const UserLoader(),
        );
      },
    );
  }
}
