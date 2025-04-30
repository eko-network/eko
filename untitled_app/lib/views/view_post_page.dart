import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as prov;
import 'package:untitled_app/custom_widgets/count_down_timer.dart';

import 'package:untitled_app/widgets/loading_spinner.dart';
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
    return prov.ChangeNotifierProvider(
      create: (context) =>
          PostPageController(passedPost: post, context: context, id: id),
      builder: (context, child) {
        return PopScope(
          canPop: prov.Provider.of<PostPageController>(context, listen: false)
              .isLoggedIn(),
          child: GestureDetector(
            onTap: () =>
                prov.Provider.of<PostPageController>(context, listen: false)
                    .hideKeyboard(),
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading: false,
                leading:
                    prov.Provider.of<PostPageController>(context, listen: false)
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
                actions: (prov.Provider.of<PostPageController>(context,
                                listen: true)
                            .post ==
                        null)
                    ? null
                    : (prov.Provider.of<PostPageController>(context,
                                    listen: false)
                                .isBlockedByMe() ||
                            prov.Provider.of<PostPageController>(context,
                                    listen: false)
                                .blocksMe())
                        ? null
                        : [
                            PopupMenuButton<void Function()>(
                              itemBuilder: (context) {
                                return [
                                  if (post!.author.uid !=
                                      locator<CurrentUser>().getUID())
                                    PopupMenuItem(
                                      height: 25,
                                      value: () =>
                                          prov.Provider.of<PostPageController>(
                                                  context,
                                                  listen: false)
                                              .reportPressed(),
                                      child: Text(
                                          AppLocalizations.of(context)!.report),
                                    )
                                  else
                                    PopupMenuItem(
                                      height: 25,
                                      value: () =>
                                          prov.Provider.of<PostPageController>(
                                                  context,
                                                  listen: false)
                                              .deletePressed(),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(AppLocalizations.of(context)!
                                              .delete),
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
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
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
              body: prov.Provider.of<PostPageController>(context, listen: true)
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
                  : prov.Provider.of<PostPageController>(context, listen: true)
                              .post ==
                          null
                      ? const Center(child: LoadingSpinner())
                      : (prov.Provider.of<PostPageController>(context,
                                      listen: false)
                                  .isBlockedByMe() ||
                              prov.Provider.of<PostPageController>(context,
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
                                //             prov.Provider.of<PostPageController>(
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
                                    index:
                                        !prov.Provider.of<PostPageController>(
                                                    context,
                                                    listen: false)
                                                .isAtSymbolTyped
                                            ? 0
                                            : 1,
                                    children: [
                                      PaginationPage(
                                          externalData: prov.Provider.of<
                                                      PostPageController>(
                                                  context,
                                                  listen: true)
                                              .data,
                                          getter: prov.Provider.of<
                                                      PostPageController>(
                                                  context,
                                                  listen: false)
                                              .getCommentsFromPost,
                                          card: commentCardBuilder,
                                          header: const _Header(),
                                          startAfterQuery:
                                              prov.Provider.of<PostPageController>(
                                                      context,
                                                      listen: false)
                                                  .getTimeFromPost),
                                      prov.Provider.of<PostPageController>(
                                                  context,
                                                  listen: true)
                                              .isLoading
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          : prov.Provider.of<
                                                          PostPageController>(
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
                                                  itemCount: prov.Provider.of<
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
                                                        prov.Provider.of<
                                                                    PostPageController>(
                                                                context,
                                                                listen: false)
                                                            .updateTextField(
                                                                username,
                                                                prov.Provider.of<
                                                                            PostPageController>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .commentFeild,
                                                                prov.Provider.of<
                                                                            PostPageController>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .commentFeildFocus);
                                                      },
                                                      uid: prov.Provider.of<
                                                                  PostPageController>(
                                                              context,
                                                              listen: true)
                                                          .hits[index]
                                                          .uid,
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
                                          focusNode: prov.Provider.of<
                                                      PostPageController>(
                                                  context,
                                                  listen: false)
                                              .commentFeildFocus,
                                          readOnly: !prov.Provider.of<
                                                      PostPageController>(
                                                  context,
                                                  listen: false)
                                              .isLoggedIn(),
                                          //  enableInteractiveSelection:
                                          //     !prov.Provider.of<PostPageController>(
                                          //             context,
                                          //             listen: false)
                                          //         .isLoggedIn(),
                                          onTap: () {
                                            if (!prov.Provider.of<
                                                        PostPageController>(
                                                    context,
                                                    listen: false)
                                                .isLoggedIn()) {
                                              prov.Provider.of<
                                                          PostPageController>(
                                                      context,
                                                      listen: false)
                                                  .showLogInDialog();
                                            }
                                          },
                                          onChanged: (s) {
                                            prov.Provider.of<
                                                        PostPageController>(
                                                    context,
                                                    listen: false)
                                                .updateCount(s);
                                            prov.Provider.of<
                                                        PostPageController>(
                                                    context,
                                                    listen: false)
                                                .checkAtSymbol(s);
                                          },
                                          maxLines: null,
                                          controller: prov.Provider.of<
                                                      PostPageController>(
                                                  context,
                                                  listen: false)
                                              .commentFeild,
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.all(height * 0.01),
                                            hintText: prov.Provider.of<
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
                                                    if (prov.Provider.of<
                                                                PostPageController>(
                                                            context,
                                                            listen: false)
                                                        .isLoggedIn()) {
                                                      prov.Provider.of<
                                                                  PostPageController>(
                                                              context,
                                                              listen: false)
                                                          .addGifPressed();
                                                    } else {
                                                      prov.Provider.of<
                                                                  PostPageController>(
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
                                                    if (prov.Provider.of<
                                                                PostPageController>(
                                                            context,
                                                            listen: false)
                                                        .isLoggedIn()) {
                                                      prov.Provider.of<
                                                                  PostPageController>(
                                                              context,
                                                              listen: false)
                                                          .postCommentPressed();
                                                    } else {
                                                      prov.Provider.of<
                                                                  PostPageController>(
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
          post:
              prov.Provider.of<PostPageController>(context, listen: true).post!,
          isBuiltFromId:
              prov.Provider.of<PostPageController>(context, listen: false)
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
