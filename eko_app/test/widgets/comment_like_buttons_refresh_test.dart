import 'dart:async';

import 'package:eko_app/providers/comment_provider.dart';
import 'package:eko_app/types/comment.dart';
import 'package:eko_app/widgets/common/count.dart';
import 'package:eko_app/widgets/posts/comment_like_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _commentId = 77;

class _FakeComment extends Comment {
  static int Function() likesGetter = () => 0;

  @override
  FutureOr<CommentModel> build(int id) {
    return CommentModel(
      uid: 'author',
      id: id,
      postId: 42,
      likes: likesGetter(),
      createdAt: '2020-01-01T00:00:00.000Z',
    );
  }
}

class _CommentHost extends ConsumerWidget {
  const _CommentHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncComment = ref.watch(commentProvider(_commentId));
    return asyncComment.when(
      data: (comment) => Scaffold(
        body: Center(child: CommentLikeButtons(comment: comment)),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

void main() {
  testWidgets(
    'comment like count refreshes after returning from view likes page',
    (tester) async {
      var serverLikes = 0;
      _FakeComment.likesGetter = () => serverLikes;

      final container = ProviderContainer(
        overrides: [commentProvider(_commentId).overrideWith(_FakeComment.new)],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, __) => const _CommentHost()),
          GoRoute(
            path: '/feed/comment/:id/likes',
            builder: (context, state) {
              serverLikes =
                  1; // Simulate another user liking while we are here.
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
            path: '/feed/comment/:id/dislikes',
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
    },
  );
}
