import 'package:eko_app/types/comment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/types/post.dart';
import 'package:eko_app/utilities/supabase_ref.dart';

Future<(int, List<PollOptionModel>?)> uploadPost(
  PostModel post,
  List<String>? pollOptions,
  WidgetRef ref,
) async {
  final fixedPost = post.copyWith(
    createdAt: DateTime.now().toUtc().toIso8601String(),
  );
  final uid = ref.read(currentUserProvider).user.uid;

  final result = await supabase.rpc(
    'insert_post',
    params: {
      'p_created_at': fixedPost.createdAt,
      'p_author_uid': uid,
      'p_title': (fixedPost.title?.isNotEmpty ?? false)
          ? fixedPost.title
          : null,
      'p_body': (fixedPost.body?.isNotEmpty ?? false) ? fixedPost.body : null,
      'p_gif': fixedPost.gifUrl,
      'p_poll': pollOptions,
      'p_image_base64': fixedPost.imageString?.toStorableString(),
      'p_ekoed_id': fixedPost.repostId,
    },
  );

  final row = result as Map;
  final postId = (row['o_post_id'] as num).toInt();
  final rawPoll = row['o_poll_data'] as List?;
  final List<PollOptionModel>? poll;
  if (rawPoll != null) {
    poll = rawPoll.map((v) => PollOptionModel.fromJson(v)).toList();
  } else {
    poll = null;
  }

  return (postId, poll);
}

Future<int> uploadComment(CommentModel comment, WidgetRef ref) async {
  final uid = ref.read(currentUserProvider).user.uid;

  debugPrint(comment.gifUrl);
  final result = await supabase.rpc(
    'insert_comment',
    params: {
      'p_created_at': comment.createdAt,
      'p_author_uid': uid,
      'p_body': (comment.body?.isNotEmpty ?? false) ? comment.body : null,
      'p_gif': comment.gifUrl,
      'p_parent_post_id': comment.postId,
    },
  );

  return result;
}
