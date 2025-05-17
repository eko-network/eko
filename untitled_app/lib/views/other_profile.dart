import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/warning_dialog.dart';
import 'package:untitled_app/interfaces/post_queries.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/user_provider.dart';
import 'package:untitled_app/types/user.dart';
import 'package:untitled_app/widgets/infinite_scrolly.dart';
import 'package:untitled_app/widgets/loading_spinner.dart';
import 'package:untitled_app/custom_widgets/profile_page_header.dart';
import 'package:untitled_app/widgets/post_loader.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import '../utilities/constants.dart' as c;
import '../widgets/post_card.dart';

class OtherProfile extends ConsumerWidget {
  final String uid;
  const OtherProfile({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
    final userAsync = ref.watch(userProvider(uid));
    final currentUser = ref.watch(currentUserProvider);

    // Check if we're viewing our own profile
    if (currentUser.user.uid == uid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/profile');
      });
    }

    // Check if the user is blocked
    final isBlockedByMe = userAsync.when(
      data: (profileUser) => currentUser.blockedUsers.contains(profileUser.uid),
      loading: () => false,
      error: (_, __) => false,
    );

    final blocksMe = userAsync.when(
      data: (profileUser) => currentUser.blockedBy.contains(profileUser.uid),
      loading: () => false,
      error: (_, __) => false,
    );

    void popDialog() {
      Navigator.of(context, rootNavigator: true).pop();
    }

    void blockUser() async {
      popDialog();
      final currentUser = ref.read(currentUserProvider.notifier);
      await currentUser.blockUser(uid);
      if (context.mounted) {
        // Navigate back to feed
        context.go('/feed', extra: true);
      }
    }

    void showBlockDialog() {
      showMyDialog(
        AppLocalizations.of(context)!.blockTitle,
        AppLocalizations.of(context)!.blockBody,
        [
          AppLocalizations.of(context)!.cancel,
          AppLocalizations.of(context)!.block
        ],
        [popDialog, blockUser],
        context,
        dismissable: true,
      );
    }

    Future<void> onRefresh() async {
      return await ref.refresh(userProvider(uid));
    }

    return PopScope(
        canPop: true,
        child: Scaffold(
          appBar: userAsync.when(
            data: (profileUser) => (isBlockedByMe || blocksMe)
                ? AppBar(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    surfaceTintColor: Colors.transparent,
                    automaticallyImplyLeading: false,
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                      onPressed: () => context.pop(),
                    ),
                  )
                : null,
            loading: () => AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
                onPressed: () => context.pop(),
              ),
            ),
            error: (_, __) => AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          body: userAsync.when(
            data: (profileUser) {
              if (isBlockedByMe || blocksMe) {
                return Center(
                  child: SizedBox(
                    width: width * 0.7,
                    child: Text(
                        AppLocalizations.of(context)!.blockedByUserMessage),
                  ),
                );
              }
              return InfiniteScrolly<String, String>(
                getter: (data) async {
                  return await otherProfilePageGetter(data, ref, uid);
                },
                widget: otherProfilePostCardBuilder,
                onRefresh: onRefresh,
                initialLoadingWidget: PostLoader(
                  length: 3,
                ),
                header: _Header(user: profileUser),
                appBar: SliverAppBar(
                  floating: true,
                  pinned: false,
                  scrolledUnderElevation: 0.0,
                  centerTitle: false,
                  leadingWidth:
                      null, //ref.read(authProvider).uid == null ? 100 : null,
                  leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                      onPressed: () => context.pop('popped')),

                  // ref.read(authProvider).uid != null
                  //              ? IconButton(
                  //                  icon: Icon(
                  //                    Icons.arrow_back_ios_rounded,
                  //                    color: Theme.of(context).colorScheme.onSurface,
                  //                    size: 20,
                  //                  ),
                  //                  onPressed: () => context.pop('popped'))
                  //              : TextButton(
                  //                  onPressed: () {
                  //                    context.go('/');
                  //                  },
                  //                  child: Text(AppLocalizations.of(context)!.signIn)),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '@${profileUser.username}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (profileUser.isVerified)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.verified_rounded,
                            size: c.verifiedIconSize,
                            color: Theme.of(context).colorScheme.surfaceTint,
                          ),
                        ),
                    ],
                  ),
                  // ref.read(authProvider).uid != null
                  //              ? Row(
                  //                  mainAxisAlignment: MainAxisAlignment.center,
                  //                  children: [
                  //                    Text(
                  //                      '@${profileUser.username}',
                  //                      style: TextStyle(
                  //                        fontWeight: FontWeight.bold,
                  //                        fontSize: 20,
                  //                        color: Theme.of(context).colorScheme.onSurface,
                  //                      ),
                  //                    ),
                  //                    if (profileUser.isVerified)
                  //                      Padding(
                  //                        padding: const EdgeInsets.only(left: 6),
                  //                        child: Icon(
                  //                          Icons.verified_rounded,
                  //                          size: c.verifiedIconSize,
                  //                          color:
                  //                              Theme.of(context).colorScheme.surfaceTint,
                  //                        ),
                  //                      ),
                  //                  ],
                  //                )
                  //              : null,
                  actions: [
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: PopupMenuButton<void Function()>(
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              height: 25,
                              value: () => showBlockDialog(),
                              child: Text(AppLocalizations.of(context)!.block),
                            )
                          ];
                        },
                        onSelected: (fn) => fn(),
                        color: Theme.of(context).colorScheme.outlineVariant,
                        child: Icon(
                          Icons.more_vert,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(3),
                    child: Divider(
                      color: Theme.of(context).colorScheme.outline,
                      height: c.dividerWidth,
                    ),
                  ),
                ),
              );
            },
            // getter: (time) =>
            //     locator<PostsHandling>().getSubProfilePosts(time, uid),
            loading: () => const Center(child: LoadingSpinner()),
            error: (error, stack) => Center(
              child: Text('Error loading user profile: $error'),
            ),
          ),
        ));
  }
}

class _Header extends ConsumerWidget {
  final UserModel user;
  const _Header({required this.user});

  Future<void> _onFollowPressed(WidgetRef ref) async {
    final isFollowing =
        ref.watch(currentUserProvider).user.following.contains(user.uid);

    if (isFollowing) {
      await ref.read(currentUserProvider.notifier).removeFollower(user.uid);
    } else {
      await ref.read(currentUserProvider.notifier).addFollower(user.uid);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
    final currentUser = ref.watch(currentUserProvider);
    final isFollowing = currentUser.user.following.contains(user.uid);

    return Column(
      children: [
        ProfileHeader(
          user: user,
          loggedIn: true, //authState.uid != null,
        ),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Center(
              child: InkWell(
                onTap: () => _onFollowPressed(ref),
                child: Container(
                  width: width * 0.45,
                  height: width * 0.09,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: isFollowing
                        ? Theme.of(context).colorScheme.surfaceContainer
                        : Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Text(
                    isFollowing
                        ? AppLocalizations.of(context)!.following
                        : AppLocalizations.of(context)!.follow,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            )),
        Divider(
          color: Theme.of(context).colorScheme.outline,
          height: c.dividerWidth,
        ),
      ],
    );
  }
}
