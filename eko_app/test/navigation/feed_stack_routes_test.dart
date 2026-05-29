import 'package:eko_app/views/feed_page.dart';
import 'package:eko_app/views/view_post_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/navigation_harness.dart';

void main() {
  setUpAll(() async {
    await ensureNavigationTestPrefs();
  });

  testWidgets('/feed/post/:id opens ViewPostPage when post is in pool', (
    tester,
  ) async {
    final container = await pumpNavigationApp(
      tester,
      overrides: signedInNavigationOverrides(),
    );

    goRouter(container).go('/feed/post/$testPostId');
    await pumpNavFrames(tester);

    expect(currentRouterUri(container).path, '/feed/post/$testPostId');
    expect(find.byType(ViewPostPage), findsOneWidget);
  });

  testWidgets('invalid post id falls back to FeedPage', (tester) async {
    final container = await pumpNavigationApp(
      tester,
      overrides: signedInNavigationOverrides(),
    );

    goRouter(container).go('/feed/post/not-an-int');
    await pumpNavFrames(tester);

    expect(currentRouterUri(container).path, '/feed/post/not-an-int');
    expect(find.byType(FeedPage), findsWidgets);
  });
}
