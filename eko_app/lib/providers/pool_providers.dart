import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eko_app/providers/comment_provider.dart';
import 'package:eko_app/providers/post_provider.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/types/comment.dart';
import 'package:eko_app/types/post.dart';
import 'package:eko_app/types/user.dart';
import 'package:eko_app/utilities/cache_service.dart';

part '../generated/providers/pool_providers.g.dart';

@Riverpod(keepAlive: true)
PoolService<PostModel, int> postPool(Ref ref) {
  return PoolService<PostModel, int>(
    onInsert: (id) {
      if (ref.exists(postProvider(id))) {
        ref.invalidate(postProvider(id));
      }
    },
    keySelector: (post) => post.id,
    validTime: const Duration(minutes: 3),
  );
}

@Riverpod(keepAlive: true)
PoolService<CommentModel, int> commentPool(Ref ref) {
  return PoolService<CommentModel, int>(
    onInsert: (id) {
      if (ref.exists(commentProvider(id))) {
        ref.invalidate(commentProvider(id));
      }
    },
    keySelector: (comment) => comment.id,
    validTime: const Duration(minutes: 3),
  );
}

@Riverpod(keepAlive: true)
PoolService<UserModel, String> userPool(Ref ref) {
  return PoolService<UserModel, String>(
    onInsert: (uid) {
      if (ref.exists(userProvider(uid))) {
        ref.invalidate(userProvider(uid));
      }
    },
    keySelector: (user) => user.uid,
    validTime: const Duration(minutes: 3),
  );
}
