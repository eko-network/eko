import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/shimmer_loaders.dart'
    show FeedLoader;
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/models/feed_post_cache.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/utilities/locator.dart';
import '../controllers/bottom_nav_bar_controller.dart';
import '../custom_widgets/profile_page_header.dart';
import '../custom_widgets/pagination.dart';
import '../custom_widgets/post_card.dart';
import '../models/post_handler.dart';
import '../utilities/constants.dart' as c;

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> onRefresh() async {
      return await ref.refresh(currentUserProvider);
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => locator<NavBarController>().goBranch(0),
      child: Scaffold(
        body: PaginationPage(
          getter: (time) => locator<PostsHandling>().getProfilePosts(time),
          card: profilePostCardBuilder,
          startAfterQuery: (post) =>
              locator<PostsHandling>().getTimeFromPost(post),
          header: const _Header(),
          initialLoadingWidget: const FeedLoader(),
          externalData: locator<FeedPostCache>().profileCache,
          extraRefresh: onRefresh,
        ),
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
