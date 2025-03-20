import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:untitled_app/custom_widgets/count_down_timer.dart';

import 'package:untitled_app/custom_widgets/loading_spinner.dart';
import 'package:untitled_app/custom_widgets/post_card.dart';

import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/custom_widgets/comment_card.dart';
import 'package:untitled_app/models/current_user.dart';
import 'package:untitled_app/utilities/locator.dart';

import '../custom_widgets/searched_user_card.dart';
import '../models/post_handler.dart' show Post;
import '../controllers/view_post_page_controller.dart';
import '../custom_widgets/pagination.dart';
import '../utilities/constants.dart' as c;

class ViewPostPage extends StatelessWidget {
  final Post? post;
  final String id;
  const ViewPostPage({super.key, required this.post, required this.id});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = c.widthGetter(context);
    return ChangeNotifierProvider(
      create: (context) =>
          PostPageController(passedPost: post, context: context, id: id),
      builder: (context, child) {
        return PopScope(
          canPop: Provider.of<PostPageController>(context, listen: false)
              .isLoggedIn(),
          child: GestureDetector(
            onTap: () => Provider.of<PostPageController>(context, listen: false)
                .hideKeyboard(),
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading: false,
                leading: Provider.of<PostPageController>(context, listen: false)
                        .isLoggedIn()
                    ? IconButton(
                        icon: Icon(Icons.arrow_back_ios_rounded,
                            color: Theme.of(context).colorScheme.onSurface),
                        onPressed: () => context.pop(),
                      )
                    : TextButton(
                        onPressed: () {
                          context.go('/');
                        },
                        child: Text(AppLocalizations.of(context)!.signIn),
                      ),
                actions: (Provider.of<PostPageController>(context, listen: true)
                              .post ==
                          null) ? null : (Provider.of<PostPageController>(context, listen: false)
                                  .isBlockedByMe() ||
                              Provider.of<PostPageController>(context,
                                      listen: false)
                                  .blocksMe())
                          ? null
                          : [
                  PopupMenuButton<void Function()>(
                    itemBuilder: (context) {
                      return [
                        if (post!.author.uid != locator<CurrentUser>().getUID())
                          PopupMenuItem(
                            height: 25,
                            value: () => Provider.of<PostPageController>(
                                    context,
                                    listen: false)
                                .reportPressed(),
                            child: Text(AppLocalizations.of(context)!.report),
                          )
                        else
                          PopupMenuItem(
                            height: 25,
                            value: () => Provider.of<PostPageController>(
                                    context,
                                    listen: false)
                                .deletePressed(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppLocalizations.of(context)!.delete),
                                CountDownTimer(
                                  dateTime: DateTime.parse(post!.time)
                                      .toLocal()
                                      .add(const Duration(hours: 48)),
                                  textStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontSize: 13),
                                )
                              ],
                            ),
                          ),
                      ];
                    },
                    onSelected: (fn) => fn(),
                    color: Theme.of(context).colorScheme.surface,
                    child: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  // IconButton(
                  //   onPressed: () {

                  //   },
                  //   icon: const Icon(Icons.more_vert),
                  //   color: Theme.of(context).colorScheme.onBackground,
                  // )
                ],
              ),
              body: Provider.of<PostPageController>(context, listen: true)
                      .postNotFound
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: width * 0.8,
                            child: Text(
                              AppLocalizations.of(context)!.postNotFound,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 23),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: width * 0.45,
                            height: width * 0.15,
                            child: TextButton(
                              onPressed: () => context.go('/feed'),
                              style: TextButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary),
                              child: Text(
                                AppLocalizations.of(context)!.exit,
                                style: TextStyle(
                                  fontSize: 18,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.normal,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Provider.of<PostPageController>(context, listen: true)
                              .post ==
                          null
                      ? const Center(child: LoadingSpinner())
                      : (Provider.of<PostPageController>(context, listen: false)
                                  .isBlockedByMe() ||
                              Provider.of<PostPageController>(context,
                                      listen: false)
                                  .blocksMe())
                          ? Center(
                              child: SizedBox(
                              width: width * 0.7,
                              child: Text(AppLocalizations.of(context)!
                                  .blockedByUserMessage),
                            ))
                          : Column(
                              children: [
                                // Row(
                                //   children: [

                                //       IconButton(
                                //         icon: Icon(Icons.arrow_back_ios_rounded,
                                //             color: Theme.of(context)
                                //                 .colorScheme
                                //                 .onBackground),
                                //         onPressed: () =>
                                //             Provider.of<PostPageController>(
                                //                     context,
                                //                     listen: false)
                                //                 .onExitPressed(),
                                //       )

                                //     else
                                //       TextButton(
                                //           onPressed: () {
                                //             context.go('/');
                                //           },
                                //           child: Text(
                                //               AppLocalizations.of(context)!
                                //                   .signIn))
                                //   ],
                                // ),
                                Expanded(
                                  child: IndexedStack(
                                    index: !Provider.of<PostPageController>(
                                                context,
                                                listen: false)
                                            .isAtSymbolTyped
                                        ? 0
                                        : 1,
                                    children: [
                                      PaginationPage(
                                          externalData:
                                              Provider.of<PostPageController>(
                                                      context,
                                                      listen: true)
                                                  .data,
                                          getter:
                                              Provider.of<PostPageController>(
                                                      context,
                                                      listen: false)
                                                  .getCommentsFromPost,
                                          card: commentCardBuilder,
                                          header: const _Header(),
                                          startAfterQuery:
                                              Provider.of<PostPageController>(
                                                      context,
                                                      listen: false)
                                                  .getTimeFromPost),
                                      Provider.of<PostPageController>(context,
                                                  listen: true)
                                              .isLoading
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          : Provider.of<PostPageController>(
                                                      context,
                                                      listen: true)
                                                  .hits
                                                  .isEmpty
                                              ? Center(
                                                  child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .noResultsFound,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface),
                                                  ),
                                                )
                                              : ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: Provider.of<
                                                              PostPageController>(
                                                          context,
                                                          listen: true)
                                                      .hits
                                                      .length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return UserCard(
                                                      tagSearch: true,
                                                      onCardTap: (username) {
                                                        Provider.of<PostPageController>(
                                                                context,
                                                                listen: false)
                                                            .updateTextField(
                                                                username,
                                                                Provider.of<PostPageController>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .commentFeild,
                                                                Provider.of<PostPageController>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .commentFeildFocus);
                                                      },
                                                      user: Provider.of<
                                                                  PostPageController>(
                                                              context,
                                                              listen: true)
                                                          .hits[index],
                                                    );
                                                  },
                                                ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: height * 0.08,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        width: width * 0.95,
                                        child: TextField(
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          cursorColor: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          focusNode:
                                              Provider.of<PostPageController>(
                                                      context,
                                                      listen: false)
                                                  .commentFeildFocus,
                                          readOnly:
                                              !Provider.of<PostPageController>(
                                                      context,
                                                      listen: false)
                                                  .isLoggedIn(),
                                          //  enableInteractiveSelection:
                                          //     !Provider.of<PostPageController>(
                                          //             context,
                                          //             listen: false)
                                          //         .isLoggedIn(),
                                          onTap: () {
                                            if (!Provider.of<
                                                        PostPageController>(
                                                    context,
                                                    listen: false)
                                                .isLoggedIn()) {
                                              Provider.of<PostPageController>(
                                                      context,
                                                      listen: false)
                                                  .showLogInDialog();
                                            }
                                          },
                                          onChanged: (s) {
                                            Provider.of<PostPageController>(
                                                    context,
                                                    listen: false)
                                                .updateCount(s);
                                            Provider.of<PostPageController>(
                                                    context,
                                                    listen: false)
                                                .checkAtSymbol(s);
                                          },
                                          maxLines: null,
                                          controller:
                                              Provider.of<PostPageController>(
                                                      context,
                                                      listen: false)
                                                  .commentFeild,
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.all(height * 0.01),
                                            hintText: Provider.of<
                                                            PostPageController>(
                                                        context,
                                                        listen: false)
                                                    .isLoggedIn()
                                                ? AppLocalizations.of(context)!
                                                    .addComment
                                                : AppLocalizations.of(context)!
                                                    .signInToComment,
                                            fillColor: Theme.of(context)
                                                .colorScheme
                                                .outlineVariant,
                                            filled: true,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: BorderSide.none,
                                            ),
                                            suffixIcon: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    if (Provider.of<
                                                                PostPageController>(
                                                            context,
                                                            listen: false)
                                                        .isLoggedIn()) {
                                                      Provider.of<PostPageController>(
                                                              context,
                                                              listen: false)
                                                          .addGifPressed();
                                                    } else {
                                                      Provider.of<PostPageController>(
                                                              context,
                                                              listen: false)
                                                          .showLogInDialog();
                                                    }
                                                  },
                                                  icon: const Icon(
                                                      Icons.gif_box_outlined),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    if (Provider.of<
                                                                PostPageController>(
                                                            context,
                                                            listen: false)
                                                        .isLoggedIn()) {
                                                      Provider.of<PostPageController>(
                                                              context,
                                                              listen: false)
                                                          .postCommentPressed();
                                                    } else {
                                                      Provider.of<PostPageController>(
                                                              context,
                                                              listen: false)
                                                          .showLogInDialog();
                                                    }
                                                  },
                                                  icon: const Icon(Icons.send),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
    return Column(
      children: [
        PostCard(
          isPostPage: true,
          post: Provider.of<PostPageController>(context, listen: true).post!,
          isBuiltFromId: Provider.of<PostPageController>(context, listen: false)
              .builtFromID,
        ),
        // Divider(
        //   color: Theme.of(context).colorScheme.outline,
        //   height: 1,
        // ),
      ],
    );
  }
}
