import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/loading_spinner.dart';
import 'package:untitled_app/custom_widgets/shimmer_loaders.dart'
    show FeedLoader;
import 'package:untitled_app/custom_widgets/profile_page_header.dart';
import 'package:untitled_app/models/users.dart' show AppUser;
import 'package:untitled_app/utilities/themes/dark_theme_provider.dart';
import '../controllers/other_profile_controller.dart';
import 'package:provider/provider.dart';
import '../custom_widgets/pagination.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import '../custom_widgets/post_card.dart';
import '../utilities/constants.dart' as c;

class OtherProfile extends StatelessWidget {
  final AppUser? user;
  final String id;
  const OtherProfile({super.key, required this.user, required this.id});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    return ChangeNotifierProvider(
      create: (context) =>
          OtherProfileController(context: context, passedUser: user, id: id),
      builder: (context, child) {
        return PopScope(
          canPop: Provider.of<OtherProfileController>(context, listen: false)
              .isLoggedIn(),
          child: Scaffold(
            appBar: Provider.of<OtherProfileController>(context, listen: true)
                            .loadedUser ==
                        null ||
                    (Provider.of<OtherProfileController>(context, listen: false)
                            .isBlockedByMe() ||
                        Provider.of<OtherProfileController>(context,
                                listen: false)
                            .blocksMe())
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
                    ))
                : null,
            body: Provider.of<OtherProfileController>(context, listen: true)
                        .loadedUser ==
                    null
                ? const Center(child: LoadingSpinner())
                : (Provider.of<OtherProfileController>(context, listen: false)
                            .isBlockedByMe() ||
                        Provider.of<OtherProfileController>(context,
                                listen: false)
                            .blocksMe())
                    ? Center(
                        child: SizedBox(
                        width: width * 0.7,
                        child: Text(
                            AppLocalizations.of(context)!.blockedByUserMessage),
                      ))
                    : PaginationPage(
                        appbar: Provider.of<OtherProfileController>(context,
                                        listen: true)
                                    .loadedUser ==
                                null
                            ? null
                            : SliverAppBar(
                                floating: true,
                                pinned: false,
                                scrolledUnderElevation: 0.0,
                                centerTitle: false,
                                leadingWidth:
                                    !Provider.of<OtherProfileController>(
                                                context,
                                                listen: false)
                                            .isLoggedIn()
                                        ? 100
                                        : null,
                                leading: Provider.of<OtherProfileController>(
                                            context,
                                            listen: false)
                                        .isLoggedIn()
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.arrow_back_ios_rounded,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          size: 20,
                                        ),
                                        onPressed: () => context.pop("popped"))
                                    : TextButton(
                                        onPressed: () {
                                          context.go('/');
                                        },
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .signIn)),
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                title: Provider.of<OtherProfileController>(
                                            context,
                                            listen: false)
                                        .isLoggedIn()
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "@${Provider.of<OtherProfileController>(context, listen: true).loadedUser!.username}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                          ),
                                          if (Provider.of<
                                                      OtherProfileController>(
                                                  context,
                                                  listen: true)
                                              .loadedUser!
                                              .isVerified)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 6),
                                              child: Icon(
                                                Icons.verified_rounded,
                                                size: c.verifiedIconSize,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surfaceTint,
                                              ),
                                            ),
                                        ],
                                      )
                                    : null,
                                actions: [
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 16, right: 16),
                                    child: PopupMenuButton<void Function()>(
                                      itemBuilder: (context) {
                                        return [
                                          PopupMenuItem(
                                            height: 25,
                                            value: () => Provider.of<
                                                        OtherProfileController>(
                                                    context,
                                                    listen: false)
                                                .showBlock(),
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .block),
                                          )
                                        ];
                                      },
                                      onSelected: (fn) => fn(),
                                      color:
                                          Theme.of(context).colorScheme.outlineVariant,
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
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    height: c.dividerWidth,
                                  ),
                                ),
                              ),
                        getter: Provider.of<OtherProfileController>(context,
                                listen: false)
                            .getPosts,
                        card: otherProfilePostCardBuilder,
                        startAfterQuery: Provider.of<OtherProfileController>(
                                context,
                                listen: false)
                            .getTimeFromPost,
                        header: const _Header(),
                        externalData: Provider.of<OtherProfileController>(
                                context,
                                listen: false)
                            .loadedPostData,
                        extraRefresh: Provider.of<OtherProfileController>(
                                context,
                                listen: false)
                            .onPageRefresh,
                        initialLoadingWidget: const FeedLoader(),
                      ),
          ),
        );
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
        Consumer<OtherProfileController>(
          builder: (context, otherProfileController, _) => ProfileHeader(
            user: otherProfileController.loadedUser!,
            loggedIn: otherProfileController.isLoggedIn(),
          ),
        ),
        //TODO style
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: width * 0.4,
                height: width * 0.1,
                child: Provider.of<OtherProfileController>(context,
                                listen: true)
                            .loadedUser ==
                        null
                    ? null
                    : TextButton(
                        style: TextButton.styleFrom(
                          side: BorderSide(
                              width: 2,
                              color:
                                  Theme.of(context).colorScheme.onSurface),
                        ),
                        onPressed: () => Provider.of<OtherProfileController>(
                                context,
                                listen: false)
                            .onFollowPressed(),
                        child: Text(
                          Provider.of<OtherProfileController>(context,
                                      listen: true)
                                  .following
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
