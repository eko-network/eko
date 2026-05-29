import 'dart:async';
import 'package:eko_app/widgets/posts/markdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/widgets/posts/count_down_timer.dart';
import 'package:eko_app/widgets/posts/gif_widget.dart';
import 'package:eko_app/widgets/common/time_stamp.dart';
import 'package:eko_app/widgets/errors/dialogs.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:eko_app/providers/comment_provider.dart';
import 'package:eko_app/providers/comment_list_provider.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/pool_providers.dart';
import 'package:eko_app/providers/post_provider.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/types/comment.dart';
import 'package:eko_app/widgets/posts/comment_like_buttons.dart';
import 'package:eko_app/widgets/users/profile_picture.dart';
import 'package:eko_app/widgets/loading/shimmer_loaders.dart';
import 'package:eko_app/widgets/users/user_tag.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:flutter/cupertino.dart';

class CommentCard extends ConsumerStatefulWidget {
  final int id;
  final Function(String username) onReply;

  const CommentCard({super.key, required this.id, required this.onReply});
  @override
  ConsumerState<CommentCard> createState() => _CommentCardState();
}

class _Error extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(AppLocalizations.of(context)!.defaultErrorTitle);
  }
}

class _Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const UserLoader();
  }
}

class _CommentCardState extends ConsumerState<CommentCard> {
  final scrollController = ScrollController();

  Future<void> scrollToStart() async {
    if (scrollController.offset != 0) {
      await scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 80),
        curve: Curves.linear,
      );
    }
  }

  Future<void> scrollToEnd() async {
    await scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 80),
      curve: Curves.linear,
    );
  }

  void onScrollEnd(WidgetRef ref, CommentModel comment) async {
    Timer(const Duration(milliseconds: 1), () {
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
          widget.onReply(ref.watch(userProvider(comment.uid)).value!.username);
        } else {
          scrollToStart();
        }
      }
    });
  }

  void _popDialog() {
    context.pop();
  }

  void _deletePostFromDialog(CommentModel comment) async {
    _popDialog();
    try {
      await ref.read(commentProvider(comment.id).notifier).deleteComment();
      ref
          .read(commentListProvider(comment.postId).notifier)
          .removeById(comment.id);
      final post = ref.read(postProvider(comment.postId)).value;
      if (post != null) {
        final nextCount = post.commentCount > 0 ? post.commentCount - 1 : 0;
        ref.read(postPoolProvider).put(post.copyWith(commentCount: nextCount));
      } else {
        ref.invalidate(postProvider(comment.postId));
      }
    } catch (e) {
      debugPrint(e.toString());
      print(e.toString());
      if (!mounted) return;
      showSnackBar(
        text: AppLocalizations.of(context)!.defaultErrorTitle,
        context: context,
      );
    }
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
          AppLocalizations.of(context)!.delete,
        ],
        [_popDialog, () => _deletePostFromDialog(comment)],
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
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTapDown: (v) => scrollToStart(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        width: width,
                        child: _Card(comment: comment, onReply: widget.onReply),
                      ),
                    ),
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
                                    dateTime: DateTime.parse(
                                      comment.createdAt,
                                    ).toLocal().add(const Duration(hours: 48)),
                                    textStyle: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          : const Icon(
                              CupertinoIcons.arrow_turn_up_left,
                              size: 32,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        debugPrint(error.toString());
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
  final Function(String username) onReply;

  const _Card({required this.comment, required this.onReply});

  Future<void> avatarPressed(
    BuildContext context,
    WidgetRef ref,
    CommentModel comment,
  ) async {
    if (comment.uid == ref.watch(currentUserProvider).user.uid) {
      context.go('/profile');
    } else {
      final user = ref.read(userProvider(comment.uid)).value;
      if (user != null) {
        await context.push('/users/${user.username}?uid=${user.uid}');
      } else {
        await context.push('/users/_?uid=${comment.uid}');
      }
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
                      final user = ref.read(userProvider(comment.uid)).value;
                      if (user != null) {
                        context.push('/users/${user.username}?uid=${user.uid}');
                      } else {
                        context.push('/users/_?uid=${comment.uid}');
                      }
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
                                final user =
                                    ref.read(userProvider(comment.uid)).value;
                                if (user != null) {
                                  context.push(
                                    '/users/${user.username}?uid=${user.uid}',
                                  );
                                } else {
                                  context.push('/users/_?uid=${comment.uid}');
                                }
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
                      MarkdownView(content: comment.body ?? ''),
                      if (comment.gifUrl != null)
                        GifWidget(url: comment.gifUrl!),
                      const SizedBox(height: 4.0),
                      TextButton(
                        onPressed: () {
                          onReply(
                            ref
                                .watch(userProvider(comment.uid))
                                .value!
                                .username,
                          );
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
                Column(
                  children: [
                    TimeStamp(time: comment.getDateTime()),
                    CommentLikeButtons(comment: comment),
                  ],
                ),
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
