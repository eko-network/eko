import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/warning_dialog.dart';
import 'package:untitled_app/models/feed_post_cache.dart';
import 'package:untitled_app/models/post_handler.dart';
import 'package:untitled_app/providers/auth_provider.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/user_provider.dart';
import 'package:untitled_app/utilities/locator.dart';
import 'package:untitled_app/widgets/loading_spinner.dart';
import 'package:untitled_app/custom_widgets/shimmer_loaders.dart'
    show FeedLoader;
import 'package:untitled_app/custom_widgets/profile_page_header.dart';
import '../custom_widgets/pagination.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import '../custom_widgets/post_card.dart';
import '../utilities/constants.dart' as c;

class OtherProfile extends ConsumerWidget {
  final String uid;
  const OtherProfile({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
    final userAsync = ref.watch(userProvider(uid));
    final authState = ref.watch(authProvider);
    final currentUser = ref.watch(currentUserProvider);
    final Cache loadedPostData = Cache(items: [], end: false);

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
        canPop: authState.uid != null,
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
              return PaginationPage(
                appbar: SliverAppBar(
                  floating: true,
                  pinned: false,
                  scrolledUnderElevation: 0.0,
                  centerTitle: false,
                  leadingWidth: ref.read(authProvider).uid == null ? 100 : null,
                  leading: ref.read(authProvider).uid != null
                      ? IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 20,
                          ),
                          onPressed: () => context.pop('popped'))
                      : TextButton(
                          onPressed: () {
                            context.go('/');
                          },
                          child: Text(AppLocalizations.of(context)!.signIn)),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  title: ref.read(authProvider).uid != null
                      ? Row(
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
                                  color:
                                      Theme.of(context).colorScheme.surfaceTint,
                                ),
                              ),
                          ],
                        )
                      : null,
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
                getter: (time) =>
                    locator<PostsHandling>().getSubProfilePosts(time, uid),
                card: otherProfilePostCardBuilder,
                startAfterQuery: (post) =>
                    locator<PostsHandling>().getTimeFromPost(post),
                header: _Header(uid: uid),
                externalData: loadedPostData,
                extraRefresh: onRefresh,
                initialLoadingWidget: const FeedLoader(),
              );
            },
            loading: () => const Center(child: LoadingSpinner()),
            error: (error, stack) => Center(
              child: Text('Error loading user profile: $error'),
            ),
          ),
        ));
  }
}

class _Header extends ConsumerStatefulWidget {
  final String uid;
  const _Header({required this.uid});

  @override
  ConsumerState<_Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<_Header> {
  bool _isFollowing = false;
  bool _isFollowingInProgress = false;

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(currentUserProvider);
    _isFollowing = currentUser.user.following.contains(widget.uid);
  }

  Future<void> _onFollowPressed() async {
    final auth = ref.read(authProvider);

    // Check if user is logged in
    if (auth.uid == null) {
      _showLogInDialog();
      return;
    }

    // Prevent multiple follow/unfollow operations at once
    if (!_isFollowingInProgress) {
      setState(() {
        _isFollowingInProgress = true;
      });

      try {
        final success = _isFollowing
            ? await _unfollowUser(widget.uid)
            : await _followUser(widget.uid);

        if (success) {
          setState(() {
            _isFollowing = !_isFollowing;
          });

          ref.invalidate(userProvider(widget.uid));
        }
      } finally {
        setState(() {
          _isFollowingInProgress = false;
        });
      }
    }
  }

  Future<bool> _followUser(String uid) async {
    try {
      final currentUser = ref.read(currentUserProvider.notifier);
      await currentUser.addFollower(uid);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _unfollowUser(String uid) async {
    try {
      final currentUser = ref.read(currentUserProvider.notifier);
      await currentUser.removeFollower(uid);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _showLogInDialog() {
    showMyDialog(
      AppLocalizations.of(context)!.logIntoApp,
      AppLocalizations.of(context)!.logInRequired,
      [
        AppLocalizations.of(context)!.goBack,
        AppLocalizations.of(context)!.signIn
      ],
      [
        () => Navigator.of(context, rootNavigator: true).pop(),
        () => context.go('/')
      ],
      context,
      dismissable: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final user = ref.watch(userProvider(widget.uid)).value;
    final authState = ref.watch(authProvider);

    return Column(
      children: [
        ProfileHeader(
          user: user!,
          loggedIn: authState.uid != null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: width * 0.4,
                height: width * 0.1,
                child: TextButton(
                  style: TextButton.styleFrom(
                    side: BorderSide(
                        width: 2,
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                  onPressed: () => _onFollowPressed(),
                  child: Text(
                    _isFollowing
                        ? AppLocalizations.of(context)!.following
                        : AppLocalizations.of(context)!.follow,
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 1,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
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
