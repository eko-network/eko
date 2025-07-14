import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/activity_provider.dart';
import 'package:untitled_app/providers/comment_provider.dart';
import 'package:untitled_app/providers/group_provider.dart';
import 'package:untitled_app/providers/post_provider.dart';
import 'package:untitled_app/providers/user_provider.dart';
import 'package:untitled_app/types/activity.dart';
import 'package:untitled_app/types/comment.dart';
import 'package:untitled_app/types/group.dart';
import 'package:untitled_app/types/post.dart';
import 'package:untitled_app/types/user.dart';
import 'package:untitled_app/utilities/cache_service.dart';

part '../generated/providers/pool_providers.g.dart';

@Riverpod(keepAlive: true)
PoolService<String, GroupModel> groupPool(Ref ref) {
  return PoolService<String, GroupModel>(
    onInsert: (id) {
      if (ref.exists(groupProvider(id))) {
        ref.invalidate(groupProvider(id));
      }
    },
    keySelector: (group) => group.id,
    validTime: const Duration(minutes: 3),
  );
}

@Riverpod(keepAlive: true)
PoolService<int, PostModel> postPool(Ref ref) {
  return PoolService<int, PostModel>(
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
PoolService<int, CommentModel> commentPool(Ref ref) {
  return PoolService<int, CommentModel>(
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
PoolService<String, UserModel> userPool(Ref ref) {
  return PoolService<String, UserModel>(
    onInsert: (uid) {
      if (ref.exists(userProvider(uid))) {
        ref.invalidate(userProvider(uid));
      }
    },
    keySelector: (user) => user.uid,
    validTime: const Duration(minutes: 3),
  );
}

@Riverpod(keepAlive: true)
PoolService<String, ActivityModel> activityPool(Ref ref) {
  return PoolService<String, ActivityModel>(
    onInsert: (id) {
      if (ref.exists(activityProvider(id))) {
        ref.invalidate(activityProvider(id));
      }
    },
    keySelector: (activity) => activity.id,
    validTime: const Duration(minutes: 3),
  );
}
