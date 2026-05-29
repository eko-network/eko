import 'package:flutter_test/flutter_test.dart';

import '../support/navigation_harness.dart';

void main() {
  setUpAll(() async {
    await ensureNavigationTestPrefs();
  });

  testWidgets('shell routes reachable via go()', (tester) async {
    final container = await pumpNavigationApp(
      tester,
      overrides: signedInNavigationOverrides(),
    );
    final router = goRouter(container);

    router.go('/feed');
    await pumpNavFrames(tester);
    expect(currentRouterUri(container).path, '/feed');

    router.go('/messages');
    await pumpNavFrames(tester);
    expect(currentRouterUri(container).path, '/messages');

    router.go('/profile');
    await pumpNavFrames(tester);
    expect(currentRouterUri(container).path, '/users/$testUsername');
    expect(currentRouterUri(container).queryParameters['uid'], testUid);
  });
}
