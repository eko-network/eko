import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:untitled_app/providers/post_provider.dart';
import 'package:untitled_app/types/post.dart';
import 'package:untitled_app/utilities/cache_service.dart';

part '../generated/providers/post_cache_provider.g.dart';

@Riverpod(keepAlive: true)
CacheService<PostModel> postCache(Ref ref) {
  return CacheService<PostModel>(
    onInsert: (id) {
      ref.invalidate(postProvider(id));
    },
    keySelector: (post) => post.id,
    validTime: const Duration(minutes: 3),
  );
}
