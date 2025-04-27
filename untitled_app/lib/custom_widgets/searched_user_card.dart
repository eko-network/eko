import 'package:flutter/material.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/models/users.dart';
import '../models/current_user.dart';
import '../utilities/locator.dart';
import 'package:provider/provider.dart' as prov;
import 'controllers/searched_user_controller.dart';
import '../custom_widgets/profile_avatar.dart';
import '../utilities/constants.dart' as c;

Widget searchPageBuilder(dynamic user) {
  return UserCard(user: user);
}

Widget blockedPageBuilder(dynamic user) {
  return UserCard(
    user: user,
    blockedPage: true,
  );
}

class UserCard extends StatelessWidget {
  final bool blockedPage;
  final bool? initialBool;
  final AppUser user;
  final bool groupSearch;
  final bool tagSearch;
  final Function(String)? onCardTap;
  final void Function(AppUser, bool)? adder;
  const UserCard(
      {super.key,
      required this.user,
      this.blockedPage = false,
      this.groupSearch = false,
      this.tagSearch = false,
      this.onCardTap,
      this.adder,
      this.initialBool});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    return prov.ChangeNotifierProvider.value(
      value: SearchedUserController(
          blockPage: blockedPage,
          user: user,
          context: context,
          groupSearch: groupSearch,
          adder: adder,
          initialBool: initialBool),
      builder: (context, child) {
        return (!blockedPage &&
                (prov.Provider.of<SearchedUserController>(context,
                            listen: false)
                        .isBlockedByMe() ||
                    prov.Provider.of<SearchedUserController>(context,
                            listen: false)
                        .blocksMe()))
            ? const SizedBox.shrink()
            : InkWell(
                onTap: () {
                  if (groupSearch) {
                    prov.Provider.of<SearchedUserController>(context,
                            listen: false)
                        .onAddPressed();
                  } else if (tagSearch) {
                    onCardTap!(user.username);
                  } else {
                    prov.Provider.of<SearchedUserController>(context,
                            listen: false)
                        .onCardPressed();
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: height * 0.01, horizontal: 6),
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
                                    if (user.name != '')
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
                                      ),
                                    Text(
                                      '@${user.username}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                      if (user.uid == locator<CurrentUser>().getUID())
                        Container()
                      else if (groupSearch)
                        Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: prov.Provider.of<SearchedUserController>(
                                        context,
                                        listen: true)
                                    .added
                                ? const Icon(Icons.check_circle)
                                : const Icon(Icons.circle_outlined))
                      else if (tagSearch)
                        Container()
                      else if (blockedPage)
                        InkWell(
                          onTap: () => prov.Provider.of<SearchedUserController>(
                                  context,
                                  listen: false)
                              .unblockPressed(),
                          child: Container(
                            width: width * 0.25,
                            height: width * 0.1,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant),
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
                          onTap: () => prov.Provider.of<SearchedUserController>(
                                  context,
                                  listen: false)
                              .onFollowPressed(),
                          child: Container(
                            width: width * 0.25,
                            height: width * 0.08,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              color: prov.Provider.of<SearchedUserController>(
                                          context,
                                          listen: true)
                                      .following
                                  ? Theme.of(context).colorScheme.outlineVariant
                                  : Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                            ),
                            child: Text(
                              prov.Provider.of<SearchedUserController>(context,
                                          listen: true)
                                      .following
                                  ? AppLocalizations.of(context)!.following
                                  : AppLocalizations.of(context)!.follow,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 13,
                                //letterSpacing: 1,
                                //fontWeight: FontWeight.normal,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              );
      },
    );
  }
}
