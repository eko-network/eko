import 'dart:async';

import 'package:eko_app/providers/post_provider.dart';
import 'package:eko_app/types/post.dart';
import 'package:eko_app/widgets/common/count.dart';
import 'package:eko_app/widgets/posts/like_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _postId = 42;

class _FakePost extends Post {
  static int Function() likesGetter = () => 0;

  @override
  FutureOr<PostModel> build(int id) {
    return PostModel(
      uid: 'author',
      id: id,
      likes: likesGetter(),
      createdAt: '2020-01-01T00:00:00.000Z',
    );
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
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

void main() {
  testWidgets('like count refreshes after returning from view likes page', (
    tester,
  ) async {
    var serverLikes = 0;
    _FakePost.likesGetter = () => serverLikes;

    final container = ProviderContainer(
      overrides: [postProvider(_postId).overrideWith(_FakePost.new)],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const _PostHost()),
        GoRoute(
          path: '/feed/post/:id/likes',
          builder: (context, state) {
            serverLikes = 1; // Simulate another user liking while we are here.
            return Scaffold(
              body: Center(
                child: TextButton(
                  key: const Key('back'),
                  onPressed: () => context.pop(),
                  child: const Text('back'),
                ),
              ),
            );
          },
        ),
        GoRoute(
          path: '/feed/post/:id/dislikes',
          builder: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.widget<Count>(find.byType(Count).first).count, 0);

    await tester.tap(find.byType(Count).first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('back')), findsOneWidget);

    await tester.tap(find.byKey(const Key('back')));
    await tester.pumpAndSettle();

    expect(tester.widget<Count>(find.byType(Count).first).count, 1);
  });
}
