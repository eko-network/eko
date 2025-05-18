import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart' as prov;
import 'package:untitled_app/custom_widgets/count_down_timer.dart';
import 'package:untitled_app/interfaces/post.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/post_pool_provider.dart';
import 'package:untitled_app/providers/post_provider.dart';
import 'package:untitled_app/types/post.dart';
import 'package:untitled_app/utilities/enums.dart';
import 'package:untitled_app/views/profile_page.dart';
import 'package:untitled_app/widgets/divider.dart';

import 'package:untitled_app/widgets/loading_spinner.dart';
import 'package:untitled_app/widgets/post_card.dart';

import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/custom_widgets/comment_card.dart';
import 'package:untitled_app/utilities/locator.dart';

import '../custom_widgets/searched_user_card.dart';
// import '../controllers/view_post_page_controller.dart';
import '../custom_widgets/pagination.dart';
import '../utilities/constants.dart' as c;
import '../widgets/infinite_scrolly.dart';
import '../widgets/post_loader.dart';

class ViewPostPage extends ConsumerStatefulWidget {
  final String id;
  const ViewPostPage({super.key, required this.id});

  @override
  ConsumerState<ViewPostPage> createState() => _ViewPostPageState();
}

class _ViewPostPageState extends ConsumerState<ViewPostPage> {
  bool isAtSymbolTyped = false;
  FocusNode commentFieldFocus = FocusNode();
  final TextEditingController commentField = TextEditingController();

  void reportPressed() {
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     final height = MediaQuery.sizeOf(context).height;
    //     return AlertDialog(
    //       backgroundColor: Theme.of(context).colorScheme.outlineVariant,
    //       title: Text(
    //         AppLocalizations.of(context)!.reportDetails,
    //         style: const TextStyle(fontSize: 18),
    //       ),
    //       content: SingleChildScrollView(
    //         child: ConstrainedBox(
    //           constraints: BoxConstraints(maxHeight: height * 0.5),
    //           child: TextField(
    //             textCapitalization: TextCapitalization.sentences,
    //             focusNode: reportFocus,

    //             // onChanged: (s) {
    //             //   prov.Provider.of<ComposeController>(context, listen: false)
    //             //       .updateCountsBody(s);
    //             //   prov.Provider.of<ComposeController>(context, listen: false)
    //             //       .checkAtSymbol(s);
    //             // },
    //             controller: reportController,

    //             maxLines: null,
    //             maxLength: 300,
    //             cursorColor: Theme.of(context).colorScheme.onSurface,
    //             keyboardType: TextInputType.multiline,
    //             style: TextStyle(
    //                 fontSize: 18,
    //                 fontWeight: FontWeight.normal,
    //                 color: Theme.of(context).colorScheme.onSurface),
    //             decoration: InputDecoration(
    //               contentPadding: EdgeInsets.all(height * 0.01),
    //               hintText: AppLocalizations.of(context)!.addText,
    //               hintStyle: TextStyle(
    //                   fontSize: 18,
    //                   fontWeight: FontWeight.normal,
    //                   color: Theme.of(context).colorScheme.onSurfaceVariant),
    //               //border: InputBorder.none,
    //             ),
    //           ),
    //         ),

    //         //  CustomInputField(
    //         //   focus: reportFocus,
    //         //   label: AppLocalizations.of(context)!.comments,
    //         //   controller: reportController,
    //         //   inputType: TextInputType.multiline,
    //         // ),
    //       ),
    //       actions: <Widget>[
    //         TextButton(
    //           child: Text(AppLocalizations.of(context)!.cancel),
    //           onPressed: () {
    //             _popDialog();
    //           },
    //         ),
    //         TextButton(
    //           child: Text(AppLocalizations.of(context)!.send),
    //           onPressed: () async {
    //             final message = reportController.text.trim();
    //             if (message != '') {
    //               reportController.text = '';
    //               await locator<PostsHandling>()
    //                   .addReport(post: post!, message: message);
    //               _popDialog();
    //             } else {
    //               showSnackBar(
    //                   context: context,
    //                   text: AppLocalizations.of(context)!.commentRequired);
    //             }
    //             //resetPassword(countryCode);
    //           },
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  void deletePressed() {
    // if (DateTime.parse(post!.time)
    //     .toLocal()
    //     .add(const Duration(hours: 48))
    //     .difference(DateTime.now())
    //     .isNegative) {
    //   //delete
    //   showMyDialog(
    //       AppLocalizations.of(context)!.deletePostWarningTitle,
    //       AppLocalizations.of(context)!.deletePostWarningBody,
    //       [
    //         AppLocalizations.of(context)!.cancel,
    //         AppLocalizations.of(context)!.delete
    //       ],
    //       [_popDialog, _deletePostFromDialog],
    //       context);
    // } else {
    //   //too early
    //   showMyDialog(
    //       AppLocalizations.of(context)!.tooEarlyDeleteTitle,
    //       AppLocalizations.of(context)!.tooEarlyDeleteBody,
    //       [AppLocalizations.of(context)!.ok],
    //       [_popDialog],
    //       context);
    // }
  }

  void checkAtSymbol(String text) {
    // bool wasAtSymbolTyped = isAtSymbolTyped;
    // int start = text.lastIndexOf('@');
    // if (start != -1 && start < text.length - 1) {
    //   int end = text.indexOf(' ', start);
    //   if (end == -1) {
    //     // No space found after '@'
    //     isAtSymbolTyped = true;
    //     onSearchTextChanged(text.substring(start + 1));
    //   } else if (text.substring(end).contains('@')) {
    //     // Another '@' found after space
    //     isAtSymbolTyped = true;
    //     onSearchTextChanged(text.substring(start + 1, end));
    //   } else {
    //     // Space found after '@' and no other '@' found
    //     isAtSymbolTyped = false;
    //   }
    // } else {
    //   isAtSymbolTyped = false;
    // }
    // if (wasAtSymbolTyped != isAtSymbolTyped) {
    //   notifyListeners();
    // }
  }

  addGifPressed() async {
    // locator<NavBarController>().disable();
    // GiphyGif? newGif = await GiphyGet.getGif(
    //   context: context,
    //   apiKey: dotenv.env['GIPHY_API_KEY']!,
    //   lang: GiphyLanguage.english,
    //   //randomID: "abcd", // Optional - An ID/proxy for a specific user.
    //   tabColor: Colors.teal,
    //   debounceTimeInMilliseconds: 350,
    // );
    // //only update gif a gif was selected
    // if (newGif != null) {
    //   gif = newGif;
    //   postCommentPressed();
    // }
    // notifyListeners();
    // locator<NavBarController>().enable();
  }

  Future<void> postCommentPressed() async {
    // if (gif == null) {
    //   commentFeild.text = commentFeild.text.trim();
    //   updateCount(commentFeild.text);

    //   if (chars > c.maxCommentChars) {
    //     showSnackBar(
    //         text: AppLocalizations.of(context)!.tooManyChar, context: context);
    //   } else if (commentFeild.text == '') {
    //     commentFeildFocus.requestFocus();
    //     showSnackBar(
    //         text: AppLocalizations.of(context)!.emptyFieldError,
    //         context: context);
    //   } else {
    //     String comment = commentFeild.text;
    //     commentFeild.text = '';
    //     hideKeyboard();
    //     final returnedId = await locator<PostsHandling>().createComment(
    //         {'body': comment}, post!.postId, post!.author.uid, post!.postId);

    //     final newComment = RawPostObject(
    //       image: null,
    //       tags: ['public'],
    //       author: locator<CurrentUser>().getUID(),
    //       likes: 0,
    //       time: DateTime.now().toUtc().toIso8601String(),
    //       body: comment,
    //       postID: returnedId,
    //       gifSource: null,
    //       gifUrl: null,
    //       title: null,
    //       dislikes: 0,
    //     );
    //     data.items.add(Post.fromRaw(
    //         newComment, AppUser.fromCurrent(locator<CurrentUser>()), 0,
    //         rootPostId: post!.postId));
    //   }
    // } else {
    //   final returnedId = await locator<PostsHandling>().createComment(
    //       {'gifUrl': gif!.images!.fixedWidth.url, 'gifSource': gif!.url},
    //       post!.postId,
    //       post!.author.uid,
    //       post!.postId);
    //   final newComment = Post(
    //       tags: ['public'],
    //       author: AppUser.fromCurrent(locator<CurrentUser>()),
    //       likes: 0,
    //       time: DateTime.now().toUtc().toIso8601String(),
    //       gifSource: gif!.url,
    //       gifURL: gif!.images!.fixedWidth.url,
    //       rootPostId: post!.postId,
    //       postId: returnedId,
    //       commentCount: 0,
    //       dislikes: 0);
    //   data.items.add(newComment);
    //   // if (post!.hasCache) {
    //   //   locator<FeedPostCache>().updateComments(post!.postId, 1);
    //   //   if (builtFromID) {
    //   //     post!.commentCount++;
    //   //   }
    //   // } else {
    //   //postMap[post!.postId]!.post.commentCount++;
    //   //post!.commentCount++;
    //   // }
    //   gif = null;
    //   //notifyListeners();
    // }
    // postMap[post!.postId]!.post.commentCount++;
    // notifyListeners();
  }

  Future<(List<MapEntry<String, String>>, bool)> getter(
      List<MapEntry<String, String>> list, WidgetRef ref) async {
    // final uid = ref.read(currentUserProvider).user.uid;
    final baseQuery = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.id)
        .collection('comments')
        .orderBy('time', descending: false)
        .limit(c.postsOnRefresh);
    final query =
        list.isEmpty ? baseQuery : baseQuery.startAfter([list.last.value]);
    final commentList = await Future.wait(
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
    final onlyPosts = commentList.map((item) => item.key).toList();
    ref.read(postPoolProvider).putAll(onlyPosts);
    //     .map<Future<Post>>((raw) async {
    //   return Post.fromRaw(raw, AppUser.fromCurrent(locator<CurrentUser>()),
    //       await countComments(raw.postID),
    //       group: (raw.tags.contains('public'))
    //           ? null
    //           : await GroupHandler().getGroupFromId(raw.tags.first),
    //       hasCache: true);
    // }).toList();
    final retList =
        commentList.map((item) => MapEntry(item.key.id, item.value)).toList();
    return (retList, retList.length < c.postsOnRefresh);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = c.widthGetter(context);
    final asyncPost = ref.watch(postProvider(widget.id));

    Future<void> onRefresh() async {
      // await ref.read(currentUserProvider.notifier).reload();
    }

    return asyncPost.when(
      data: (post) {
        // TODO: handle if blocked
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded,
                    color: Theme.of(context).colorScheme.onSurface),
                onPressed: () => context.pop(),
              ),
              actions: [
                PopupMenuButton<void Function()>(
                  itemBuilder: (context) {
                    return [
                      if (post.uid != ref.read(currentUserProvider).user.uid)
                        PopupMenuItem(
                          height: 25,
                          value: () => reportPressed(),
                          child: Text(AppLocalizations.of(context)!.report),
                        )
                      else
                        PopupMenuItem(
                          height: 25,
                          value: () => deletePressed(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppLocalizations.of(context)!.delete),
                              CountDownTimer(
                                dateTime: post.createdAt
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
                  color: Theme.of(context).colorScheme.outlineVariant,
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
            body: Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: isAtSymbolTyped ? 1 : 0,
                    children: [
                      // PaginationPage(
                      //     externalData: prov.Provider.of<PostPageController>(
                      //             context,
                      //             listen: true)
                      //         .data,
                      //     getter: prov.Provider.of<PostPageController>(context,
                      //             listen: false)
                      //         .getCommentsFromPost,
                      //     card: commentCardBuilder,
                      //     header: const _Header(),
                      //     startAfterQuery: prov.Provider.of<PostPageController>(
                      //             context,
                      //             listen: false)
                      //         .getTimeFromPost),
                      InfiniteScrolly<String, String>(
                        getter: (data) => getter(data, ref),
                        widget: profilePostCardBuilder,
                        header: _Header(id: widget.id),
                        onRefresh: onRefresh,
                        // initialLoadingWidget: PostLoader(
                        //   length: 3,
                        // ),
                      ),
                      // prov.Provider.of<PostPageController>(context,
                      //             listen: true)
                      //         .isLoading
                      //     ? const Center(
                      //         child: CircularProgressIndicator(),
                      //       )
                      //     : prov.Provider.of<PostPageController>(context,
                      //                 listen: true)
                      //             .hits
                      //             .isEmpty
                      //         ? Center(
                      //             child: Text(
                      //               AppLocalizations.of(context)!
                      //                   .noResultsFound,
                      //               style: TextStyle(
                      //                   fontSize: 18,
                      //                   color: Theme.of(context)
                      //                       .colorScheme
                      //                       .onSurface),
                      //             ),
                      //           )
                      //         : ListView.builder(
                      //             shrinkWrap: true,
                      //             itemCount:
                      //                 prov.Provider.of<PostPageController>(
                      //                         context,
                      //                         listen: true)
                      //                     .hits
                      //                     .length,
                      //             itemBuilder:
                      //                 (BuildContext context, int index) {
                      //               return UserCard(
                      //                 tagSearch: true,
                      //                 onCardTap: (username) {
                      //                   prov.Provider.of<PostPageController>(
                      //                           context,
                      //                           listen: false)
                      //                       .updateTextField(
                      //                           username,
                      //                           prov.Provider.of<
                      //                                       PostPageController>(
                      //                                   context,
                      //                                   listen: false)
                      //                               .commentFeild,
                      //                           prov.Provider.of<
                      //                                       PostPageController>(
                      //                                   context,
                      //                                   listen: false)
                      //                               .commentFieldFocus);
                      //                 },
                      //                 uid: prov.Provider.of<PostPageController>(
                      //                         context,
                      //                         listen: true)
                      //                     .hits[index]
                      //                     .uid,
                      //               );
                      //             },
                      //           ),
                    ],
                  ),
                ),
                SizedBox(
                  height: height * 0.08,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: width * 0.95,
                        child: TextField(
                          textCapitalization: TextCapitalization.sentences,
                          cursorColor: Theme.of(context).colorScheme.onSurface,
                          focusNode: commentFieldFocus,
                          onChanged: (s) {
                            checkAtSymbol(s);
                          },
                          maxLines: null,
                          controller: commentField,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(height * 0.01),
                            hintText: AppLocalizations.of(context)!.addComment,
                            fillColor:
                                Theme.of(context).colorScheme.outlineVariant,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => addGifPressed(),
                                  icon: const Icon(Icons.gif_box_outlined),
                                ),
                                IconButton(
                                  onPressed: () => postCommentPressed(),
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
        );
      },
      error: (error, stackTrace) {
        return Center(
          child: Text(
            AppLocalizations.of(context)!.postNotFound,
          ),
        );
      },
      loading: () {
        return const Center(
          child: LoadingSpinner(),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final String id;
  const _Header({required this.id});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PostCard(
          id: id,
          isPostPage: true,
        ),
        StyledDivider(),
      ],
    );
  }
}
