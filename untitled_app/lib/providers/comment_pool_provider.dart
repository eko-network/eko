import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/comment_provider.dart';
import 'package:untitled_app/types/comment.dart';
import 'package:untitled_app/utilities/cache_service.dart';

part '../generated/providers/comment_pool_provider.g.dart';

@Riverpod(keepAlive: true)
PoolService<CommentModel> commentPool(Ref ref) {
  return PoolService<CommentModel>(
    onInsert: (id) {
      if (ref.exists(commentProvider(id))) {
        ref.invalidate(commentProvider(id));
      }
    },
    keySelector: (comment) => comment.id,
    validTime: const Duration(minutes: 3),
  );
}
