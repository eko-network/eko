import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:like_button/like_button.dart';
import 'package:untitled_app/providers/post_provider.dart';
import 'package:untitled_app/types/post.dart';
import 'package:untitled_app/utilities/like_state.dart';
import 'package:untitled_app/widgets/icons.dart' as icons;
import '../utilities/constants.dart' as c;

class Count extends StatelessWidget {
  final int count;
  final void Function()? onTap;
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

class LikeButtons extends ConsumerWidget {
  final PostModel post;
  final bool disabled;
  const LikeButtons({super.key, required this.post, this.disabled = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fillColor = Color(0xFFFF3040);
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LikeButton(
            isLiked: !disabled &&
                post.likeState ==
                    LikeState
                        .liked, //!disabled && user.likedPosts.contains(post.id),
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
              if (!disabled) {
                ref.read(postProvider(post.id).notifier).likePostToggle();
                return !isLiked;
              }
              return isLiked;
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
            count: post.likes,
            onTap: disabled
                ? null
                : () {
                    context.push('/feed/post/${post.id}/likes', extra: post.id);
                  },
          ),
          LikeButton(
            isLiked: !disabled && post.likeState == LikeState.disliked,
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
              if (!disabled) {
                ref.read(postProvider(post.id).notifier).dislikePostToggle();
                return !isDisliked;
              }
              return isDisliked;
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
            count: post.dislikes,
            onTap: disabled
                ? null
                : () {
                    context.push('/feed/post/${post.id}/dislikes',
                        extra: post.id);
                  },
          )
        ]);
  }
}
