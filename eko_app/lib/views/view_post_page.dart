import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/widgets/posts/count_down_timer.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:eko_app/widgets/errors/dialogs.dart';
import 'package:eko_app/interfaces/post.dart';
import 'package:eko_app/interfaces/report.dart';
import 'package:eko_app/providers/comment_list_provider.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/pool_providers.dart';
import 'package:eko_app/providers/post_provider.dart';
import 'package:eko_app/types/comment.dart';

import 'package:eko_app/widgets/loading/loading_spinner.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/widgets/posts/post_card.dart';
import 'package:eko_app/widgets/search/tag_search.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/widgets/posts/comment_card.dart';
import 'package:eko_app/widgets/common/infinite_scrolly.dart';
import 'package:eko_app/widgets/scaffolds/app_scaffold.dart';
import 'package:eko_app/widgets/scaffolds/eko_app_bar.dart';

class ViewPostPage extends ConsumerStatefulWidget {
  final int id;
  const ViewPostPage({super.key, required this.id});

  @override
  ConsumerState<ViewPostPage> createState() => _ViewPostPageState();
}

class _ViewPostPageState extends ConsumerState<ViewPostPage> {
  bool isUploading = false;
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
    commentFieldFocus.dispose();
    commentField.dispose();
    reportController.dispose();
    super.dispose();
  }

  void _popDialog() {
    context.pop();
  }

  KeyEventResult _handleCommentFieldKey(FocusNode _, KeyEvent event) {
    final isMobileApp =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final isEnter =
        event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;
    if (isMobileApp ||
        event is! KeyDownEvent ||
        !isEnter ||
        HardwareKeyboard.instance.isShiftPressed) {
      return KeyEventResult.ignored;
    }

    postCommentPressed();
    return KeyEventResult.handled;
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
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(height * 0.01),
                  hintText: AppLocalizations.of(context)!.addText,
                  hintStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
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
                    text: AppLocalizations.of(context)!.commentRequired,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deletePostFromDialog() async {
    _popDialog();

    try {
      await ref.read(postProvider(widget.id).notifier).deletePost();
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        showSnackBar(
          context: context,
          text: AppLocalizations.of(context)!.defaultErrorTitle,
        );
      }
    }
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
          AppLocalizations.of(context)!.delete,
        ],
        [_popDialog, _deletePostFromDialog],
        context,
      );
    } else {
      //too early
      showSnackBar(
        text: AppLocalizations.of(context)!.tooEarlyDeleteBody,
        context: context,
      );
    }
  }

  Future<void> addGifPressed() async {
    String? url = await context.pushNamed('gif');
    if (url != null) {
      gif = url;
      postCommentPressed();
    }
  }

  Future<void> postCommentPressed() async {
    if (isUploading) return;
    try {
      isUploading = true;
      CommentModel? comment;

      if (gif == null) {
        commentField.text = commentField.text.trim();
        if (commentField.text.length > c.maxCommentChars) {
          showSnackBar(
            text: AppLocalizations.of(context)!.tooManyChar,
            context: context,
            variant: SnackBarVariant.destructive,
          );
          return;
        } else if (commentField.text == '') {
          commentFieldFocus.requestFocus();
          showSnackBar(
            text: AppLocalizations.of(context)!.commentCantBeEmpty,
            context: context,
            variant: SnackBarVariant.destructive,
          );
          return;
        } else {
          String body = commentField.text;
          commentField.text = '';
          FocusManager.instance.primaryFocus?.unfocus();
          comment = CommentModel(
            uid: ref.read(currentUserProvider).user.uid,
            id: 0,
            postId: widget.id,
            createdAt: DateTime.now().toUtc().toIso8601String(),
            body: body,
          );
        }
      } else {
        comment = CommentModel(
          uid: ref.read(currentUserProvider).user.uid,
          id: 0,
          postId: widget.id,
          createdAt: DateTime.now().toUtc().toIso8601String(),
          gifUrl: gif,
        );
        gif = null;
      }

      final id = await uploadComment(comment, ref);
      final completeComment = comment.copyWith(id: id);

      // Add comment to the comment list
      ref.read(commentPoolProvider).putAll([completeComment]);
      ref
          .read(commentListProvider(widget.id).notifier)
          .addToBack(completeComment);

      // Increment comment count
      final post = ref.read(postProvider(widget.id)).value;
      if (post != null) {
        final updatedPost = post.copyWith(commentCount: post.commentCount + 1);
        ref.read(postPoolProvider).putAll([updatedPost]);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (commentsScrollController.hasClients) {
          commentsScrollController.animateTo(
            commentsScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        showSnackBar(
          text: AppLocalizations.of(context)!.defaultErrorTitle,
          context: context,
          variant: SnackBarVariant.destructive,
        );
      }
    } finally {
      isUploading = false;
    }
  }

  void replyPressed(String username) {
    commentFieldFocus.requestFocus();
    commentField.text = '@$username ';
  }

  Widget commentCardBuilder(int id) {
    return CommentCard(id: id, onReply: (username) => replyPressed(username));
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
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: AppScaffold(
            appBar: EkoAppBar(
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
                                dateTime: DateTime.parse(
                                  post.createdAt,
                                ).toLocal().add(const Duration(hours: 48)),
                                textStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
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
                  child: Stack(
                    children: [
                      InfiniteScrollyCore<int>(
                        isEnd: provider.$2,
                        list: provider.$1,
                        header: PostCard(id: widget.id, isPostPage: true),
                        getter: () => ref
                            .read(commentListProvider(widget.id).notifier)
                            .getter(widget.id),
                        onRefresh: onRefresh,
                        widget: commentCardBuilder,
                        controller: commentsScrollController,
                      ),
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          commentFieldFocus,
                          commentField,
                        ]),
                        builder: (context, _) {
                          final text = searchText(commentField);
                          if (text != null && commentFieldFocus.hasFocus) {
                            return TagSearch(
                              onCardTap: (username) =>
                                  onCardTap(username, commentField),
                              searchText: text,
                            );
                          }
                          return SizedBox();
                        },
                      ),
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
                        child: Focus(
                          onKeyEvent: _handleCommentFieldKey,
                          child: TextField(
                            textCapitalization: TextCapitalization.sentences,
                            cursorColor: Theme.of(
                              context,
                            ).colorScheme.onSurface,
                            focusNode: commentFieldFocus,
                            maxLines: null,
                            controller: commentField,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(height * 0.01),
                              hintText: AppLocalizations.of(
                                context,
                              )!.addComment,
                              fillColor: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
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
                                  ),
                                ],
                              ),
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
        return Center(child: Text(AppLocalizations.of(context)!.postNotFound));
      },
      loading: () {
        return const Center(child: LoadingSpinner());
      },
    );
  }
}
