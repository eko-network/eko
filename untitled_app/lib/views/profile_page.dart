import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as prov;
import 'package:untitled_app/custom_widgets/shimmer_loaders.dart'
    show FeedLoader;
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/models/feed_post_cache.dart';
import 'package:untitled_app/utilities/locator.dart';
import '../custom_widgets/profile_page_header.dart';
import '../controllers/profile_controller.dart';
import '../custom_widgets/pagination.dart';
import '../custom_widgets/post_card.dart';
import '../utilities/constants.dart' as c;

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return prov.ChangeNotifierProvider(
      create: (context) => ProfileController(context: context),
      builder: (context, child) {
        return PopScope(
            canPop: false,
            onPopInvoked: (didPop) =>
                prov.Provider.of<ProfileController>(context, listen: false)
                    .onWillPop(),
            child: Scaffold(
              body: PaginationPage(
                  getter: prov.Provider.of<ProfileController>(context,
                          listen: false)
                      .getProfilePosts,
                  card: profilePostCardBuilder,
                  startAfterQuery: prov.Provider.of<ProfileController>(context,
                          listen: false)
                      .getTimeFromPost,
                  header: const _Header(),
                  initialLoadingWidget: const FeedLoader(),
                  externalData: locator<FeedPostCache>().profileCache,
                  extraRefresh: prov.Provider.of<ProfileController>(context,
                          listen: false)
                      .onPageRefresh),
            ));
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    return Column(
      children: [
        prov.Consumer<ProfileController>(
          builder: (context, profileController, _) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    Text(
                      '@${profileController.user.username}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (profileController.user.isVerified)
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
                      onTap: () => prov.Provider.of<ProfileController>(context,
                              listen: false)
                          .qrButtonPressed(),
                      child: Icon(
                        Icons.qr_code,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 22,
                        weight: 10,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: InkWell(
                        onTap: () => prov.Provider.of<ProfileController>(
                                context,
                                listen: false)
                            .settingsButtonPressed(),
                        child: Icon(
                          Icons.settings_outlined,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 22,
                          weight: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ProfileHeader(
                user: profileController.user,
              ),
            ],
          ),
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
                  onPressed: () => prov.Provider.of<ProfileController>(context,
                          listen: false)
                      .editProfilePressed(),
                  child: Text(
                    AppLocalizations.of(context)!.editProfile,
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
