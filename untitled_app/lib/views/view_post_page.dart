import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/count_down_timer.dart';
import 'package:untitled_app/custom_widgets/error_snack_bar.dart';
import 'package:untitled_app/custom_widgets/warning_dialog.dart';
import 'package:untitled_app/interfaces/post.dart';
import 'package:untitled_app/interfaces/post_queries.dart';
import 'package:untitled_app/interfaces/report.dart';
import 'package:untitled_app/providers/comment_list_provider.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/nav_bar_provider.dart';
import 'package:untitled_app/providers/pool_providers.dart';
import 'package:untitled_app/providers/post_provider.dart';
import 'package:untitled_app/types/comment.dart';

import 'package:untitled_app/widgets/loading_spinner.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/widgets/post_card.dart';
import '../utilities/constants.dart' as c;
import '../widgets/comment_card.dart';
import '../widgets/infinite_scrolly.dart';

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
  String? gif;
  final reportFocus = FocusNode();
  final reportController = TextEditingController();
  final ScrollController commentsScrollController = ScrollController();

  @override
  void dispose() {
    commentsScrollController.dispose();
    super.dispose();
  }

  void _popDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void reportPressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final height = MediaQuery.sizeOf(context).height;
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.outlineVariant,
          title: Text(
            AppLocalizations.of(context)!.reportDetails,
            style: const TextStyle(fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: height * 0.5),
              child: TextField(
                textCapitalization: TextCapitalization.sentences,
                focusNode: reportFocus,
                controller: reportController,
                maxLines: null,
                maxLength: 300,
                cursorColor: Theme.of(context).colorScheme.onSurface,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(height * 0.01),
                  hintText: AppLocalizations.of(context)!.addText,
                  hintStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                _popDialog();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.send),
              onPressed: () async {
                final message = reportController.text.trim();
                if (message != '') {
                  reportController.text = '';
                  await addReport(ref, widget.id, message);
                  _popDialog();
                } else {
                  showSnackBar(
                      context: context,
                      text: AppLocalizations.of(context)!.commentRequired);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deletePostFromDialog() {
    context.pop();
    // TODO: delete post (after sql) didnt want to do now since appcheck wasnt working
  }

  void deletePressed(String createdAt) {
    if (DateTime.parse(createdAt)
        .toLocal()
        .add(const Duration(hours: 48))
        .difference(DateTime.now())
        .isNegative) {
      //delete
      showMyDialog(
          AppLocalizations.of(context)!.deletePostWarningTitle,
          AppLocalizations.of(context)!.deletePostWarningBody,
          [
            AppLocalizations.of(context)!.cancel,
            AppLocalizations.of(context)!.delete
          ],
          [_popDialog, _deletePostFromDialog],
          context);
    } else {
      //too early
      showMyDialog(
          AppLocalizations.of(context)!.tooEarlyDeleteTitle,
          AppLocalizations.of(context)!.tooEarlyDeleteBody,
          [AppLocalizations.of(context)!.ok],
          [_popDialog],
          context);
    }
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
    String? url = await context.pushNamed('gif');
    if (url != null) {
      gif = url;
      postCommentPressed();
    }
  }

  Future<void> postCommentPressed() async {
    CommentModel? comment;

    if (gif == null) {
      commentField.text = commentField.text.trim();
      if (commentField.text.length > c.maxCommentChars) {
        showSnackBar(
            text: AppLocalizations.of(context)!.tooManyChar, context: context);
        return;
      } else if (commentField.text == '') {
        commentFieldFocus.requestFocus();
        showSnackBar(
            text: AppLocalizations.of(context)!.emptyFieldError,
            context: context);
        return;
      } else {
        String body = commentField.text;
        commentField.text = '';
        FocusManager.instance.primaryFocus?.unfocus();
        comment = CommentModel(
          uid: ref.watch(currentUserProvider).user.uid,
          id: '',
          postId: widget.id,
          createdAt: DateTime.now().toUtc().toIso8601String(),
          body: parseTextToTags(body),
        );
      }
    } else {
      comment = CommentModel(
        uid: ref.watch(currentUserProvider).user.uid,
        id: '',
        postId: widget.id,
        createdAt: DateTime.now().toUtc().toIso8601String(),
        gifUrl: gif,
      );
      gif = null;
    }

    final id = await uploadComment(comment, ref);
    final completeComment = comment.copyWith(id: id);

    // Add comment to the comment list
    ref
        .read(commentListProvider(widget.id).notifier)
        .addToBack(completeComment);
    ref.read(commentPoolProvider).putAll([completeComment]);

    // Increment comment count
    final post = ref.read(postProvider(widget.id)).value;
    if (post != null) {
      final updatedPost = post.copyWith(commentCount: post.commentCount + 1);
      ref.read(postPoolProvider).putAll([updatedPost]);
    }

    if (commentsScrollController.hasClients) {
      commentsScrollController.animateTo(
        commentsScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void replyPressed(String username) {
    commentFieldFocus.requestFocus();
    commentField.text = '@$username ';
  }

  Widget commentCardBuilder(String id) {
    return CommentCard(
      id: id,
      onReply: (username) => replyPressed(username),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = c.widthGetter(context);
    final asyncPost = ref.watch(postProvider(widget.id));
    final provider = ref.watch(commentListProvider(widget.id));

    Future<void> onRefresh() async {
      await Future.wait([
        ref.read(currentUserProvider.notifier).reload(),
        ref.read(commentListProvider(widget.id).notifier).refresh(),
      ]);
      ref.invalidate(postProvider(widget.id));
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
                          value: () => deletePressed(post.createdAt),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppLocalizations.of(context)!.delete),
                              CountDownTimer(
                                dateTime: DateTime.parse(post.createdAt)
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
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: 
                  IndexedStack(
                    index: isAtSymbolTyped ? 1 : 0,
                    children: [
                      InfiniteScrollyShell<String>(
                        isEnd: provider.$2,
                        list: provider.$1,
                        header: PostCard(id: widget.id, isPostPage: true),
                        getter: () => ref
                            .read(commentListProvider(widget.id).notifier)
                            .getter(widget.id),
                        onRefresh: onRefresh,
                        widget: commentCardBuilder,
                        // Add the controller here
                        controller: commentsScrollController,
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
                      //                               .commentField,
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
