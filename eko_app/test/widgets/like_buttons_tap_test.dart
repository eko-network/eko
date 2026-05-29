import 'dart:async';

import 'package:eko_app/providers/post_provider.dart';
import 'package:eko_app/types/post.dart';
import 'package:eko_app/widgets/common/count.dart';
import 'package:eko_app/widgets/posts/like_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:like_button/like_button.dart';

const _postId = 100;

class _FakeLikeTogglePost extends Post {
  @override
  FutureOr<PostModel> build(int id) {
    return PostModel(
      uid: 'author',
      id: id,
      likes: 0,
      isLiked: false,
      createdAt: '2020-01-01T00:00:00.000Z',
    );
  }

  @override
  Future<void> likePostToggle() async {
    final prev = await future;
    if (prev.isLiked) {
      state = AsyncData(
        prev.copyWith(
          isLiked: false,
          likes: prev.likes > 0 ? prev.likes - 1 : 0,
        ),
      );
    } else {
      state = AsyncData(prev.copyWith(isLiked: true, likes: prev.likes + 1));
    }
  }
}

class _PostHost extends ConsumerWidget {
  const _PostHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPost = ref.watch(postProvider(_postId));
    return asyncPost.when(
      data: (post) => Scaffold(
        body: Center(child: LikeButtons(post: post)),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

void main() {
  testWidgets('tapping like toggles count up and down', (tester) async {
    final container = ProviderContainer(
      overrides: [postProvider(_postId).overrideWith(_FakeLikeTogglePost.new)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: _PostHost()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.widget<Count>(find.byType(Count).first).count, 0);

    await tester.tap(find.byType(LikeButton).first);
    await tester.pumpAndSettle();
    expect(tester.widget<Count>(find.byType(Count).first).count, 1);

    await tester.tap(find.byType(LikeButton).first);
    await tester.pumpAndSettle();
    expect(tester.widget<Count>(find.byType(Count).first).count, 0);
  });
}
