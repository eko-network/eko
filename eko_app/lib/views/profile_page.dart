import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/widgets/common/feed_options_button.dart';
import 'package:eko_app/widgets/errors/dialogs.dart';
import 'package:eko_app/interfaces/user.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/profile_post_list_provider.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/types/user.dart';
import 'package:eko_app/widgets/common/infinite_scrolly.dart';
import 'package:eko_app/widgets/loading/loading_spinner.dart';
import 'package:eko_app/widgets/users/profile_header.dart';
import 'package:eko_app/widgets/loading/shimmer_loaders.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/widgets/users/verification_badge.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/widgets/posts/post_card.dart';
import 'package:eko_app/widgets/common/max_width_content.dart';
import 'package:eko_app/widgets/scaffolds/app_scaffold.dart';
import 'package:eko_app/widgets/scaffolds/eko_app_bar.dart';

class ProfilePage extends ConsumerStatefulWidget {
  final String username;
  final String? uid;
  const ProfilePage({super.key, required this.username, this.uid});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  String? _resolvedUid;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _resolveUid();
  }

  Future<void> _resolveUid() async {
    if (widget.uid != null && widget.uid!.isNotEmpty) {
      setState(() {
        _resolvedUid = widget.uid;
      });
      return;
    }

    final me = ref.read(currentUserProvider).user;
    if (me.username == widget.username && me.uid.isNotEmpty) {
      setState(() {
        _resolvedUid = me.uid;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final uid = await getUidFromUsername(widget.username);
      if (!mounted) return;
      setState(() {
        _resolvedUid = uid;
        _isLoading = false;
        if (uid == null) {
          _error = AppLocalizations.of(context)!.userNotFound;
        }
      });
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      setState(() {
        _error = AppLocalizations.of(context)!.profileResolveFailed;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserProvider).user.uid;
    final currentUsername = ref.watch(currentUserProvider).user.username;

    final bool isMyOwnProfile =
        (widget.uid != null && widget.uid == currentUserId) ||
        (widget.uid == null && widget.username == currentUsername);

    Widget? buildLeadingWidget(BuildContext context, bool isMyProfile) {
      if (isMyProfile) {
        return SizedBox(width: 20);
      }
      return IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () => context.pop(),
      );
    }

    if (_isLoading) {
      return AppScaffold(
        appBar: EkoAppBar(
          title: _ProfileAppBarContent(
            leading: buildLeadingWidget(context, isMyOwnProfile),
            title: const SizedBox(),
            actions: const [],
          ),
        ),
        body: const Center(child: LoadingSpinner()),
      );
    }

    if (_error != null || _resolvedUid == null) {
      return AppScaffold(
        appBar: EkoAppBar(
          title: _ProfileAppBarContent(
            leading: buildLeadingWidget(context, isMyOwnProfile),
            title: const SizedBox(),
            actions: const [],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.userNotFound,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final uid = _resolvedUid!;
    final width = c.widthGetter(context);
    final userAsync = ref.watch(userProvider(uid));
    final currentUser = ref.watch(currentUserProvider);
    final bool isCurrentUser = currentUser.user.uid == uid;
    final selectedSort = isCurrentUser
        ? ref.watch(profilePostSortProvider)
        : ref.watch(otherProfilePostSortProvider(uid));
    final postListState = isCurrentUser
        ? ref.watch(profilePostListProvider)
        : ref.watch(otherProfilePostListProvider(uid));

    void popDialog() {
      context.pop();
    }

    void blockUser() async {
      popDialog();
      final currentUser = ref.read(currentUserProvider.notifier);
      await currentUser.blockUser(uid);
      if (context.mounted) {
        context.go('/feed', extra: true);
      }
    }

    void showBlockDialog() {
      showMyDialog(
        AppLocalizations.of(context)!.blockTitle,
        AppLocalizations.of(context)!.blockBody,
        [
          AppLocalizations.of(context)!.cancel,
          AppLocalizations.of(context)!.block,
        ],
        [popDialog, blockUser],
        context,
        dismissable: true,
      );
    }

    Future<void> onRefresh() async {
      final futures = <Future<void>>[
        ref.refresh(userProvider(uid).future),
        ref.read(currentUserProvider.notifier).reload(),
      ];
      if (isCurrentUser) {
        futures.add(ref.read(profilePostListProvider.notifier).refresh());
      } else {
        futures.add(
          ref.read(otherProfilePostListProvider(uid).notifier).refresh(),
        );
      }
      await Future.wait(futures);
    }

    Future<void> loadMorePosts() async {
      if (isCurrentUser) {
        await ref.read(profilePostListProvider.notifier).getter();
      } else {
        await ref.read(otherProfilePostListProvider(uid).notifier).getter();
      }
    }

    Future<void> onSortChanged(ProfilePostSort sort) async {
      if (selectedSort == sort) {
        return;
      }
      if (isCurrentUser) {
        ref.read(profilePostSortProvider.notifier).state = sort;
        await ref.read(profilePostListProvider.notifier).setSort(sort);
      } else {
        ref.read(otherProfilePostSortProvider(uid).notifier).state = sort;
        await ref
            .read(otherProfilePostListProvider(uid).notifier)
            .setSort(sort);
      }
    }

    return PopScope(
      canPop: true,
      child: AppScaffold(
        body: userAsync.when(
          data: (profileUser) {
            return InfiniteScrollyCore<int>(
              getter: loadMorePosts,
              list: postListState.$1,
              isEnd: postListState.$2,
              widget: isCurrentUser
                  ? profilePostCardBuilder
                  : otherProfilePostCardBuilder,
              onRefresh: onRefresh,
              initialLoadingWidget: PostLoader(),
              header: _Header(
                user: profileUser,
                isCurrentUser: isCurrentUser,
                sort: selectedSort,
                onSortChanged: onSortChanged,
              ),
              appBar: SliverAppBar(
                floating: true,
                pinned: false,
                scrolledUnderElevation: 0.0,
                centerTitle: false,
                automaticallyImplyLeading: false,
                backgroundColor: Theme.of(context).colorScheme.surface,
                titleSpacing: 0,
                title: _ProfileAppBarContent(
                  leading: isCurrentUser
                      ? null
                      : IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onPressed: () => context.pop(),
                        ),
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
                      if (profileUser.isVerified) VerificationBadge(uid: uid),
                    ],
                  ),
                  actions: [
                    if (isCurrentUser)
                      InkWell(
                        onTap: () {
                          context
                              .push(
                                '/users/${profileUser.username}/user_settings',
                              )
                              .then((_) => {});
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
                                child: Text(
                                  AppLocalizations.of(context)!.block,
                                ),
                              ),
                            ];
                          },
                          onSelected: (fn) => fn(),
                          color: Theme.of(context).colorScheme.outlineVariant,
                          child: Icon(
                            Icons.more_vert,
                            size: 20,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(3),
                  child: MaxWidthContent(
                    child: Divider(
                      color: Theme.of(context).colorScheme.outline,
                      height: c.dividerWidth,
                    ),
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(child: LoadingSpinner()),
          error: (error, stack) {
            debugPrint(error.toString());
            return Center(
              child: Text(AppLocalizations.of(context)!.profileLoadFailed),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileAppBarContent extends StatelessWidget {
  const _ProfileAppBarContent({
    required this.leading,
    required this.title,
    required this.actions,
  });

  final Widget? leading;
  final Widget title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return MaxWidthContent(
      child: SizedBox(
        height: kToolbarHeight,
        child: Row(
          children: [
            SizedBox(width: 8),
            SizedBox(width: 48, child: leading ?? const SizedBox()),
            const SizedBox(width: 8),
            Expanded(child: Center(child: title)),
            const SizedBox(width: 8),
            Row(mainAxisSize: MainAxisSize.min, children: actions),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  final UserModel user;
  final bool isCurrentUser;
  final ProfilePostSort sort;
  final ValueChanged<ProfilePostSort> onSortChanged;
  const _Header({
    required this.user,
    required this.isCurrentUser,
    required this.sort,
    required this.onSortChanged,
  });

  Future<void> _onFollowPressed(WidgetRef ref) async {
    await ref.read(userProvider(user.uid).notifier).toggleFollow();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
    final actionButtonWidth = (width * 0.45).clamp(120.0, 170.0).toDouble();
    final actionButtonHeight = (width * 0.09).clamp(38.0, 44.0).toDouble();
    final userState = ref.watch(userProvider(user.uid));
    final isFollowing = userState.value?.isFollowing ?? user.isFollowing;

    return Column(
      children: [
        ProfileHeader(user: user, loggedIn: true),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: isCurrentUser
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!kIsWeb)
                      InkWell(
                        onTap: () {
                          context
                              .push('/users/${user.username}/edit_profile')
                              .then((_) => {});
                        },
                        child: Container(
                          width: actionButtonWidth,
                          height: actionButtonHeight,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
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
                        context
                            .push('/users/${user.username}/share_profile')
                            .then((_) => {});
                      },
                      child: Container(
                        width: actionButtonWidth,
                        height: actionButtonHeight,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
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
                      width: actionButtonWidth,
                      height: actionButtonHeight,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
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
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: FeedOptionsButton<ProfilePostSort>(
              selectedValue: sort,
              onChanged: onSortChanged,
              options: [
                FeedOption(
                  label: AppLocalizations.of(context)!.feedTabNew,
                  value: ProfilePostSort.newest,
                ),
                FeedOption(
                  label: AppLocalizations.of(context)!.feedTabPopular,
                  value: ProfilePostSort.popular,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
