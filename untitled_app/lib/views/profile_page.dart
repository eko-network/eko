import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/nav_bar_provider.dart';
import 'package:untitled_app/types/current_user.dart';
import 'package:untitled_app/widgets/divider.dart';
import 'package:untitled_app/widgets/infinite_scrolly.dart';
import 'package:untitled_app/widgets/post_loader.dart';
import '../custom_widgets/profile_page_header.dart';
import '../utilities/constants.dart' as c;
import '../widgets/post_card.dart';
import 'package:untitled_app/interfaces/post_queries.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> onRefresh() async {
      await ref.read(currentUserProvider.notifier).reload();
    }

    return Scaffold(
      body: InfiniteScrolly<String, String>(
        getter: (data) async {
          return await profilePageGetter(data, ref);
        },
        widget: profilePostCardBuilder,
        header: _Header(currentUser: ref.watch(currentUserProvider)),
        onRefresh: onRefresh,
        initialLoadingWidget: PostLoader(
          length: 3,
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  final CurrentUserModel currentUser;
  const _Header({required this.currentUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
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
                    onTap: () {
                      ref.read(navBarProvider.notifier).disable();
                      context.push('/profile/user_settings').then(
                          (_) => ref.read(navBarProvider.notifier).enable());
                    },
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
                onTap: () {
                  ref.read(navBarProvider.notifier).disable();
                  context
                      .push('/profile/edit_profile')
                      .then((_) => ref.read(navBarProvider.notifier).enable());
                },
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
                onTap: () {
                  ref.read(navBarProvider.notifier).disable();
                  context
                      .push('/profile/share_profile')
                      .then((_) => ref.read(navBarProvider.notifier).enable());
                },
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
        StyledDivider(),
      ],
    );
  }
}
