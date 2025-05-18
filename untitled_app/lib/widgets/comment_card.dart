import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/count_down_timer.dart';
import 'package:untitled_app/custom_widgets/gif_widget.dart';
import 'package:untitled_app/custom_widgets/time_stamp.dart';
import 'package:untitled_app/custom_widgets/warning_dialog.dart';
import 'package:untitled_app/providers/comment_provider.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/types/comment.dart';
import 'package:untitled_app/widgets/comment_like_buttons.dart';
import 'package:untitled_app/widgets/profile_picture.dart';
import 'package:untitled_app/widgets/user_tag.dart';
import '../localization/generated/app_localizations.dart';
import '../utilities/constants.dart' as c;
import 'package:flutter/cupertino.dart';

Widget commentCardBuilder(String id) {
  return CommentCard(id: id);
}

class CommentCard extends ConsumerStatefulWidget {
  final String id;
  const CommentCard({super.key, required this.id});
  @override
  ConsumerState<CommentCard> createState() => _CommentCardState();
}

class _Error extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(AppLocalizations.of(context)!.defaultErrorTittle);
  }
}

class _Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _CommentCardState extends ConsumerState<CommentCard> {
  final scrollController = ScrollController();

  Future<void> scrollToStart() async {
    if (scrollController.offset != 0) {
      await scrollController.animateTo(0,
          duration: const Duration(milliseconds: 80), curve: Curves.linear);
    }
  }

  Future<void> scrollToEnd() async {
    await scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 80), curve: Curves.linear);
  }

  void onScrollEnd(WidgetRef ref, CommentModel comment) async {
    Timer(
      const Duration(milliseconds: 1),
      () {
        final scrollPercentage = scrollController.position.pixels /
            scrollController.position.maxScrollExtent;
        if (comment.uid == ref.watch(currentUserProvider).user.uid) {
          if (scrollPercentage >= 0.8) {
            scrollToEnd();
          } else {
            scrollToStart();
          }
        } else {
          if (scrollPercentage >= 0.9) {
            scrollToStart();
            // TODO: reply to comment
            // replyPressed(ref.watch(userProvider(comment.uid)).value!.username);
          } else {
            scrollToStart();
          }
        }
      },
    );
  }

  void _popDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

// TODO: delete comment
  void _deletePostFromDialog() async {
    _popDialog();
    // await locator<PostsHandling>()
    //     .deleteData('posts/${post.rootPostId}/comments/${post.postId}');

    // prov.Provider.of<PostPageController>(context, listen: false)
    //     .removeComment(post.postId);
  }

  void deletePressed(CommentModel comment) {
    scrollToStart();
    if (DateTime.parse(comment.createdAt)
        .toLocal()
        .add(const Duration(hours: 48))
        .difference(DateTime.now())
        .isNegative) {
      //delete
      showMyDialog(
          AppLocalizations.of(context)!.deleteCommentWarningTitle,
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

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final asyncComment = ref.watch(commentProvider(widget.id));
    final currentUser = ref.watch(currentUserProvider);

    return asyncComment.when(
      data: (comment) {
        return TapRegion(
          onTapOutside: (v) => scrollToStart(),
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (notification) {
              onScrollEnd(ref, comment);
              return true;
            },
            child: SingleChildScrollView(
              controller: scrollController,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: (comment.uid == currentUser.user.uid)
                        ? Colors.red
                        : Theme.of(context).colorScheme.outlineVariant),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                        onTapDown: (v) => scrollToStart(),
                        child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface),
                            width: width,
                            child: _Card(comment: comment))),
                    SizedBox(
                      width: width * 0.2,
                      //color: Colors.red,
                      child: (comment.uid == currentUser.user.uid)
                          ? GestureDetector(
                              onTap: () => deletePressed(comment),
                              child: Column(
                                children: [
                                  const Icon(
                                    CupertinoIcons.delete_simple,
                                    size: 32,
                                  ),
                                  CountDownTimer(
                                    dateTime: DateTime.parse(comment.createdAt)
                                        .toLocal()
                                        .add(const Duration(hours: 48)),
                                    textStyle: const TextStyle(fontSize: 13),
                                  )
                                ],
                              ))
                          : const Icon(
                              CupertinoIcons.arrow_turn_up_left,
                              size: 32,
                            ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        return _Error();
      },
      loading: () {
        return _Loading();
      },
    );
  }
}

class _Card extends ConsumerWidget {
  final CommentModel comment;
  const _Card({required this.comment});

  avatarPressed(
      BuildContext context, WidgetRef ref, CommentModel comment) async {
    if (comment.uid == ref.watch(currentUserProvider).user.uid) {
      await context.push('/feed/sub_profile/${comment.uid}');
    } else {
      context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: c.postPaddingHoriz,
              vertical: c.postPaddingVert,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfilePicture(
                  onPressed: () {
                    if (comment.uid != ref.read(currentUserProvider).user.uid) {
                      context.push('/feed/sub_profile/${comment.uid}');
                    } else {
                      context.go('/profile');
                    }
                  },
                  uid: comment.uid,
                  size: width * 0.115,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          UserTag(
                            onPressed: () {
                              if (comment.uid !=
                                  ref.read(currentUserProvider).user.uid) {
                                context
                                    .push('/feed/sub_profile/${comment.uid}');
                              } else {
                                context.go('/profile');
                              }
                            },
                            uid: comment.uid,
                          ),
                          const SizedBox(width: 8.0),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      if (comment.body != null)
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily:
                                  DefaultTextStyle.of(context).style.fontFamily,
                            ),
                            children: comment.body!.map((chunk) {
                              if (chunk.startsWith('@')) {
                                // This is a username, create a hyperlink
                                return TextSpan(
                                    text: chunk,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceTint),
                                    recognizer: TapGestureRecognizer()
                                    // ..onTap = () => tagPressed(chunk.substring(1)),
                                    );
                              } else {
                                // This is a normal text, create a TextSpan
                                return TextSpan(
                                  text: chunk,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                );
                              }
                            }).toList(),
                          ),
                        ),
                      if (comment.gifUrl != null)
                        GifWidget(url: comment.gifUrl!),
                      const SizedBox(height: 4.0),
                      TextButton(
                        onPressed: () {
                          // replyPressed(comment.uid);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.reply,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(children: [
                  TimeStamp(time: comment.createdAt),
                  CommentLikeButtons(comment: comment),
                ])
              ],
            ),
          ),
          Divider(
            color: Theme.of(context).colorScheme.outline,
            height: c.dividerWidth,
          ),
        ],
      ),
    );
  }
}
