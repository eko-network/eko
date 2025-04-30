import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/controllers/blocked_users_page_controller.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/providers/user_provider.dart';
import 'package:untitled_app/types/user.dart';
import '../models/current_user.dart';
import '../utilities/locator.dart';
import 'package:provider/provider.dart' as prov;
import '../custom_widgets/profile_avatar.dart';
import '../utilities/constants.dart' as c;

Widget searchPageBuilder(dynamic uid) {
  return UserCard(
    uid: uid.uid,
  );
}

Widget blockedPageBuilder(dynamic uid) {
  return UserCard(
    uid: uid.uid,
    blockedPage: true,
  );
}

class UserCard extends ConsumerStatefulWidget {
  final bool blockedPage;
  final bool? initialBool;
  //final AppUser user;
  final bool groupSearch;
  final bool tagSearch;
  final String uid;
  final Function(String)? onCardTap;
  final void Function(dynamic, bool)? adder;
  const UserCard(
      {super.key,
      //required this.user,
      required this.uid,
      this.blockedPage = false,
      this.groupSearch = false,
      this.tagSearch = false,
      this.onCardTap,
      this.adder,
      this.initialBool});

  @override
  ConsumerState<UserCard> createState() => _UserCardState();
}

class _UserCardState extends ConsumerState<UserCard> {
  late UserModel? loadedUser;
  late bool following;
  bool isFollowing = false;
  late bool added;

  @override
  void initState() {
    super.initState();
    final currentUser = locator<CurrentUser>();
    final user = ref.read(userProvider(widget.uid)).maybeWhen(
          data: (u) => u,
          orElse: () => null,
        );

    loadedUser = user;
    if (widget.groupSearch) {
      added = widget.adder != null ? widget.initialBool ?? false : false;
    } else {
      following = user != null ? currentUser.checkIsFollowing(user.uid) : false;
    }
  }

  bool isBlockedByMe(UserModel user) {
    return locator<CurrentUser>().blockedUsers.contains(user.uid);
  }

  bool blocksMe(UserModel user) {
    return locator<CurrentUser>().blockedBy.contains(user.uid);
  }

  void onCardPressed(UserModel user) {
    if (!widget.blockedPage) {
      context.push('/feed/sub_profile/${user.uid}', extra: user);
    }
  }

  void unblockPressed(UserModel user) {
    final controller =
        prov.Provider.of<BlockedUsersPageController>(context, listen: false);
    controller.unblockUser(user.uid);
  }

  Future<void> onFollowPressed(UserModel user) async {
    final currentUser = locator<CurrentUser>();
    final uid = user.uid;
    if (uid != currentUser.uid && !isFollowing) {
      isFollowing = true;
      if (following) {
        following = false;
        user.followers.remove(currentUser.uid);
        setState(() {});
        if (!(await currentUser.removeFollower(uid))) {
          following = true;
          user.followers.add(currentUser.uid);
        }
      } else {
        following = true;
        user.followers.add(currentUser.uid);
        setState(() {});
        if (!(await currentUser.addFollower(uid))) {
          following = false;
          user.followers.remove(currentUser.uid);
        }
      }
      isFollowing = false;
      setState(() {});
    }
  }

  void onAddPressed(UserModel user) {
    if (widget.adder != null) {
      widget.adder!(user, !added);
      setState(() => added = !added);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    final userAsync = ref.watch(userProvider(widget.uid));

    return userAsync.when(
      data: (user) {
        if (!widget.blockedPage && (isBlockedByMe(user) || blocksMe(user))) {
          return const SizedBox.shrink();
        }

        return InkWell(
          onTap: () {
            if (widget.groupSearch) {
              onAddPressed(user);
            } else if (widget.tagSearch) {
              widget.onCardTap?.call(user.username);
            } else {
              onCardPressed(user);
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
                    ProfileAvatar(
                        url: user.profilePicture, size: width * 0.115),
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
                if (user.uid == locator<CurrentUser>().getUID())
                  Container()
                else if (widget.groupSearch)
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: added
                        ? const Icon(Icons.check_circle)
                        : const Icon(Icons.circle_outlined),
                  )
                else if (widget.tagSearch)
                  Container()
                else if (widget.blockedPage)
                  InkWell(
                    onTap: () => unblockPressed(user),
                    child: Container(
                      width: width * 0.25,
                      height: width * 0.1,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.unblock,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  )
                else
                  InkWell(
                    onTap: () => onFollowPressed(user),
                    child: Container(
                      width: width * 0.25,
                      height: width * 0.08,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: following
                            ? Theme.of(context).colorScheme.outlineVariant
                            : Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: Text(
                        following
                            ? AppLocalizations.of(context)!.following
                            : AppLocalizations.of(context)!.follow,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      error: (err, _) => Text('Oops $err'),
      loading: () => const CircularProgressIndicator(),
    );
  }
}
