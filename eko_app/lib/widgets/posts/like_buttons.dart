import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:like_button/like_button.dart';
import 'package:eko_app/providers/post_provider.dart';
import 'package:eko_app/types/post.dart';
import 'package:eko_app/widgets/common/icons.dart' as icons;
import 'package:eko_app/widgets/common/count.dart';
import 'package:eko_app/utilities/constants.dart' as c;

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
          isLiked: !disabled && post.isLiked,
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
              : () async {
                  await context.push('/feed/post/${post.id}/likes');
                  ref.invalidate(postProvider(post.id));
                },
        ),
        LikeButton(
          isLiked: !disabled && post.isDisliked, //dislike
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
              : () async {
                  await context.push('/feed/post/${post.id}/dislikes');
                  ref.invalidate(postProvider(post.id));
                },
        ),
      ],
    );
  }
}
