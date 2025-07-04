import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:like_button/like_button.dart';
import 'package:untitled_app/providers/comment_provider.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/types/comment.dart';
import 'package:untitled_app/widgets/icons.dart' as icons;
import '../utilities/constants.dart' as c;

class Count extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const Count({
    super.key,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class CommentLikeButtons extends ConsumerWidget {
  final CommentModel comment;
  const CommentLikeButtons({super.key, required this.comment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final fillColor = Color(0xFFFF3040);
    return Column(children: [
      Row(
        children: [
          LikeButton(
            isLiked: false, //user.likedPosts.contains(comment.id),
            likeBuilder: (isLiked) {
              return icons.Like(
                size: c.postIconSize,
                fillColor: isLiked ? fillColor : null,
                strokeColor: isLiked
                    ? fillColor
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              );
            },
            onTap: (isLiked) async {
              ref
                  .read(commentProvider(comment.id).notifier)
                  .likeCommentToggle();
              return !isLiked;
            },
            likeCountAnimationType: LikeCountAnimationType.none,
            likeCountPadding: null,
            circleSize: 0,
            animationDuration: const Duration(milliseconds: 600),
            bubblesSize: 25,
            bubblesColor: const BubblesColor(
              dotPrimaryColor: Color.fromARGB(255, 52, 105, 165),
              dotSecondaryColor: Color.fromARGB(255, 65, 43, 161),
              dotThirdColor: Color.fromARGB(255, 196, 68, 211),
              dotLastColor: Color(0xFFff3040),
            ),
          ),
          Count(
            count: comment.likes,
            onTap: () {
              context.push('/feed/post/${comment.id}/likes', extra: comment.id);
            },
          ),
        ],
      ),
      Row(
        children: [
          LikeButton(
            isLiked: false, //user.dislikedPosts.contains(comment.id), //dislike
            likeBuilder: (isDisliked) {
              return icons.Dislike(
                size: c.postIconSize,
                fillColor: isDisliked ? fillColor : null,
                strokeColor: isDisliked
                    ? fillColor
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              );
            },
            onTap: (isDisliked) async {
              ref
                  .read(commentProvider(comment.id).notifier)
                  .dislikeCommentToggle();
              return !isDisliked;
            },
            likeCountAnimationType: LikeCountAnimationType.none,
            likeCountPadding: null,
            circleSize: 0,
            animationDuration: const Duration(milliseconds: 600),
            bubblesSize: 25,
            bubblesColor: const BubblesColor(
              dotPrimaryColor: Color.fromARGB(255, 52, 105, 165),
              dotSecondaryColor: Color.fromARGB(255, 65, 43, 161),
              dotThirdColor: Color.fromARGB(255, 196, 68, 211),
              dotLastColor: Color(0xFFff3040),
            ),
          ),
          Count(
            count: comment.dislikes,
            onTap: () {
              context.push('/feed/post/${comment.id}/dislikes',
                  extra: comment.id);
            },
          )
        ],
      ),
    ]);
  }
}
