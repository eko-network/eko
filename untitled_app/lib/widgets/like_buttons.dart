import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:like_button/like_button.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/post_provider.dart';
import 'package:untitled_app/types/post.dart';
import '../utilities/constants.dart' as c;

class Count extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const Count({super.key, 
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
  const LikeButtons({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LikeButton(
            isLiked: user.likedPosts.contains(post.id),
            likeBuilder: (isLiked) {
              return SvgPicture.string(
                '''
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
           fill="${isLiked ? '#FF3040' : 'none'}" 
           stroke="${isLiked ? '#FF3040' : '#${Theme.of(context).colorScheme.onSurface.toARGB32().toRadixString(16).substring(2)}'}" 
           stroke-width="1" stroke-linecap="round" stroke-linejoin="round">
        <path d="M9 18v-6H5l7-7 7 7h-4v6H9z"/>
      </svg>
      ''',
                width: c.postIconSize,
                height: c.postIconSize,
              );
            },
            onTap: (isLiked) async {
              ref.read(postProvider(post.id).notifier).likePostToggle();
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
            count: post.likes,
            onTap: () {
              context.push('/feed/post/${post.id}/likes', extra: post.id);
            },
          ),
          LikeButton(
            isLiked: user.dislikedPosts.contains(post.id), //dislike
            likeBuilder: (isDisliked) {
              return SvgPicture.string(
                '''
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
           fill="${isDisliked ? '#FF3040' : 'none'}" 
           stroke="${isDisliked ? '#FF3040' : '#${Theme.of(context).colorScheme.onSurface.toARGB32().toRadixString(16).substring(2)}'}" 
           stroke-width="1" stroke-linecap="round" stroke-linejoin="round">
        <path d="M15 6v6h4l-7 7-7-7h4V6h6z"/>
      </svg>
      ''',
                width: c.postIconSize,
                height: c.postIconSize,
              );
            },
            onTap: (isDisliked) async {
              ref.read(postProvider(post.id).notifier).dislikePostToggle();
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
            count: post.dislikes,
            onTap: () {
              context.push('/feed/post/${post.id}/dislikes', extra: post.id);
            },
          )
        ]);
  }
}
