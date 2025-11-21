import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/warning_dialog.dart';
import 'package:untitled_app/interfaces/post_queries.dart';
import 'package:untitled_app/interfaces/user.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/user_provider.dart';
import 'package:untitled_app/types/user.dart';
import 'package:untitled_app/widgets/infinite_scrolly.dart';
import 'package:untitled_app/widgets/loading_spinner.dart';
import 'package:untitled_app/custom_widgets/profile_page_header.dart';
import 'package:untitled_app/widgets/shimmer_loaders.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/widgets/verification_badge.dart';
import '../utilities/constants.dart' as c;
import '../widgets/post_card.dart';

class OtherProfile extends ConsumerStatefulWidget {
  final String username;
  final String? uid;
  const OtherProfile({super.key, required this.username, this.uid});

  @override
  ConsumerState<OtherProfile> createState() => _OtherProfileState();
}

class _OtherProfileState extends ConsumerState<OtherProfile> {
  String? _resolvedUid;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _resolveUid();
  }

  Future<void> _resolveUid() async {
    // If uid is provided, use it directly (happy path)
    if (widget.uid != null) {
      setState(() {
        _resolvedUid = widget.uid;
      });
      return;
    }

    // Otherwise, fetch uid from username
    setState(() {
      _isLoading = true;
    });

    try {
      final uid = await getUidFromUsername(widget.username);
      if (mounted) {
        setState(() {
          _resolvedUid = uid;
          _isLoading = false;
          if (uid == null) {
            _error = 'User not found';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading user';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserProvider).user.uid;
    final currentUsername = ref.watch(currentUserProvider).user.username;

    final bool isMyOwnProfile =
        (widget.uid != null && widget.uid == currentUserId) ||
            (widget.uid == null && widget.username == currentUsername);

    // Helper function to build the leading widget (back button)
    Widget? buildLeadingWidget(BuildContext context, bool isMyProfile) {
      if (isMyProfile) {
        return SizedBox(
          width: 20,
        ); // No back button for current user's own profile
      }
      return IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: Theme.of(context).colorScheme.onSurface,
          size: 20,
        ),
        onPressed: () => context.pop(),
      );
    }

    // Handle loading state while resolving UID
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: buildLeadingWidget(context, isMyOwnProfile),
        ),
        body: const Center(child: LoadingSpinner()),
      );
    }

    // Handle error state
    if (_error != null || _resolvedUid == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: buildLeadingWidget(context, isMyOwnProfile),
        ),
        body: Center(
          child: Text(_error ?? AppLocalizations.of(context)!.userNotFound),
        ),
      );
    }

    final uid = _resolvedUid!;
    final width = c.widthGetter(context);
    final userAsync = ref.watch(userProvider(uid));
    final currentUser = ref.watch(currentUserProvider);
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
    final bool isCurrentUser = currentUser.user.uid == uid;

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
                    leading: buildLeadingWidget(context, isCurrentUser),
                  )
                : null,
            loading: () => AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              leading: buildLeadingWidget(context, isCurrentUser),
            ),
            error: (_, __) => AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              leading: buildLeadingWidget(context, isCurrentUser),
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
                  if (isCurrentUser) {
                    return await profilePageGetter(data, ref);
                  } else {
                    return await otherProfilePageGetter(data, ref, uid);
                  }
                },
                widget: otherProfilePostCardBuilder,
                onRefresh: onRefresh,
                initialLoadingWidget: PostLoader(
                  length: 3,
                ),
                header: _Header(
                  user: profileUser,
                  isCurrentUser: isCurrentUser,
                ),
                appBar: SliverAppBar(
                  floating: true,
                  pinned: false,
                  scrolledUnderElevation: 0.0,
                  centerTitle: false,
                  leadingWidth:
                      null, //ref.read(authProvider).uid == null ? 100 : null,
                  leading: isCurrentUser
                      ? null
                      : IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 20,
                          ),
                          onPressed: () => context.pop('popped')),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          '@${profileUser.username}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (profileUser.isVerified)
                        VerificationBadge(
                          uid: uid,
                        )
                    ],
                  ),
                  actions: [
                    if (isCurrentUser)
                      InkWell(
                        onTap: () {
                          //ref.read(navBarProvider.notifier).disable();
                          context
                              .push(
                                  '/users/${profileUser.username}/user_settings')
                              .then((_) =>
                                  {} /*ref.read(navBarProvider.notifier).enable()*/);
                        },
                        child: Icon(
                          Icons.settings_outlined,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 25,
                          weight: 10,
                        ),
                      )
                    else
                      Padding(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: PopupMenuButton<void Function()>(
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                height: 25,
                                value: () => showBlockDialog(),
                                child:
                                    Text(AppLocalizations.of(context)!.block),
                              )
                            ];
                          },
                          onSelected: (fn) => fn(),
                          color: Theme.of(context).colorScheme.outlineVariant,
                          child: Icon(
                            Icons.more_vert,
                            size: 20,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
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
  final bool isCurrentUser;
  const _Header({required this.user, required this.isCurrentUser});

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
          child: isCurrentUser
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //the username chager doesn't work on web i think could be firebase outage
                    if (!kIsWeb)
                      InkWell(
                        onTap: () {
                          //ref.read(navBarProvider.notifier).disable();
                          context
                              .push('/users/${user.username}/edit_profile')
                              .then((_) =>
                                  {} /*ref.read(navBarProvider.notifier).enable()*/);
                        },
                        child: Container(
                          width: width * 0.45,
                          height: width * 0.09,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            color:
                                Theme.of(context).colorScheme.surfaceContainer,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.editProfile,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    if (!kIsWeb) SizedBox(width: width * 0.02),
                    InkWell(
                      onTap: () {
                        //ref.read(navBarProvider.notifier).disable();
                        context
                            .push('/users/${user.username}/share_profile')
                            .then((_) =>
                                {} /*ref.read(navBarProvider.notifier).enable()*/);
                      },
                      child: Container(
                        width: width * 0.45,
                        height: width * 0.09,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          color: Theme.of(context).colorScheme.surfaceContainer,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.shareProfile,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: InkWell(
                    onTap: () => _onFollowPressed(ref),
                    child: Container(
                      width: width * 0.45,
                      height: width * 0.09,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
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
                ),
        ),
        Divider(
          color: Theme.of(context).colorScheme.outline,
          height: c.dividerWidth,
        ),
      ],
    );
  }
}
