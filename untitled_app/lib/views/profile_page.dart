import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/shimmer_loaders.dart'
    show FeedLoader;
import 'package:untitled_app/interfaces/post.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/post_pool_provider.dart';
import 'package:untitled_app/providers/post_provider.dart';
import 'package:untitled_app/types/post.dart';
import 'package:untitled_app/utilities/enums.dart';
import 'package:untitled_app/utilities/locator.dart';
import 'package:untitled_app/widgets/infinite_scrolly.dart';
import '../controllers/bottom_nav_bar_controller.dart';
import '../custom_widgets/profile_page_header.dart';
import '../utilities/constants.dart' as c;
import '../widgets/post_card.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<(List<MapEntry<String, String>>, bool)> getter(
      List<MapEntry<String, String>> list, WidgetRef ref) async {
    final uid = ref.read(currentUserProvider).user.uid;
    final baseQuery = FirebaseFirestore.instance
        .collection('posts')
        .where('author', isEqualTo: uid)
        .orderBy('time', descending: true)
        .limit(c.postsOnRefresh);
    final query =
        list.isEmpty ? baseQuery : baseQuery.startAfter([list.last.value]);
    final postList = await Future.wait(
      await query.get().then(
            (data) => data.docs.map(
              (raw) async {
                final json = raw.data();
                json['id'] = raw.id;
                json['commentCount'] =
                    await countComments(raw.id); // commentCount;
                final post = PostModel.fromJson(json, LikeState.neutral);
                final likeState =
                    ref.read(currentUserProvider.notifier).getLikeState(raw.id);
                return MapEntry(post.copyWith(likeState: likeState),
                    json['time'] as String);
              },
            ),
          ),
    );
    final onlyPosts = postList.map((item) => item.key).toList();
    ref.read(postPoolProvider).putAll(onlyPosts);
    // start the providers going a frame early
    for (final post in onlyPosts) {
      ref.read(postProvider(post.id));
    }
    //     .map<Future<Post>>((raw) async {
    //   return Post.fromRaw(raw, AppUser.fromCurrent(locator<CurrentUser>()),
    //       await countComments(raw.postID),
    //       group: (raw.tags.contains('public'))
    //           ? null
    //           : await GroupHandler().getGroupFromId(raw.tags.first),
    //       hasCache: true);
    // }).toList();
    final retList =
        postList.map((item) => MapEntry(item.key.id, item.value)).toList();
    return (retList, retList.length < c.postsOnRefresh);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> onRefresh() async {
      await ref.read(currentUserProvider.notifier).reload();
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => locator<NavBarController>().goBranch(0),
      child: Scaffold(
          body: InfiniteScrolly<String, String>(
        getter: (data) async {
          return await getter(data, ref);
        },
        widget: profilePostCardBuilder,
        header: const _Header(),
        onRefresh: onRefresh,
        initialLoadingWidget: FeedLoader(),
      )
          // PaginationPage(
          //       getter: (time) => locator<PostsHandling>().getProfilePosts(time),
          //       card: (post) => profilePostCardBuilder(post.postId),
          //       startAfterQuery: (post) =>
          //           locator<PostsHandling>().getTimeFromPost(post),
          //       header: const _Header(),
          //       initialLoadingWidget: const FeedLoader(),
          //       externalData: locator<FeedPostCache>().profileCache,
          //       extraRefresh: onRefresh,
          //     ),
          ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  void _editProfilePressed(BuildContext context, WidgetRef ref) async {
    locator<NavBarController>().disable();
    await context.push('/profile/edit_profile');
    locator<NavBarController>().enable();
  }

  void _settingsButtonPressed(BuildContext context) async {
    locator<NavBarController>().disable();
    await context.push('/profile/user_settings');
    locator<NavBarController>().enable();
  }

  void _qrButtonPressed(BuildContext context) async {
    locator<NavBarController>().disable();
    await context.push('/profile/share_profile');
    locator<NavBarController>().enable();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
    final currentUser = ref.watch(currentUserProvider);

    return Column(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
              child: Row(
                children: [
                  Text(
                    '@${currentUser.user.username}',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (currentUser.user.isVerified)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.verified_rounded,
                        size: c.verifiedIconSize,
                        color: Theme.of(context).colorScheme.surfaceTint,
                      ),
                    ),
                  const Spacer(),
                  InkWell(
                    onTap: () => _settingsButtonPressed(context),
                    child: Icon(
                      Icons.settings_outlined,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 25,
                      weight: 10,
                    ),
                  ),
                ],
              ),
            ),
            ProfileHeader(
              user: currentUser.user,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => _editProfilePressed(context, ref),
                child: Container(
                  width: width * 0.45,
                  height: width * 0.09,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: Theme.of(context).colorScheme.surfaceContainer,
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
              SizedBox(width: width * 0.02),
              InkWell(
                onTap: () => _qrButtonPressed(context),
                child: Container(
                  width: width * 0.45,
                  height: width * 0.09,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
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
