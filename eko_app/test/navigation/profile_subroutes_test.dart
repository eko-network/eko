import 'package:eko_app/views/blocked_users_page.dart';
import 'package:eko_app/views/change_email_page.dart';
import 'package:eko_app/views/change_password_page.dart';
import 'package:eko_app/views/edit_profile.dart';
import 'package:eko_app/views/profile_page.dart';
import 'package:eko_app/views/share_profile_page.dart';
import 'package:eko_app/views/user_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/navigation_harness.dart';

void main() {
  setUpAll(() async {
    await ensureNavigationTestPrefs();
  });

  String profileBase() => '/users/$testUsername?uid=$testUid';

  testWidgets('profile stack: base profile page', (tester) async {
    final container = await pumpNavigationApp(
      tester,
      overrides: signedInNavigationOverrides(),
    );

    goRouter(container).go(profileBase());
    await pumpNavFrames(tester);

    expect(find.byType(ProfilePage), findsOneWidget);
    expect(currentRouterUri(container).path, '/users/$testUsername');
    expect(currentRouterUri(container).queryParameters['uid'], testUid);
  });

  testWidgets('profile stack: edit_profile, share_profile, user_settings', (
    tester,
  ) async {
    final container = await pumpNavigationApp(
      tester,
      overrides: signedInNavigationOverrides(),
    );
    final router = goRouter(container);

    router.go('/users/$testUsername/edit_profile?uid=$testUid');
    await pumpNavFrames(tester);
    expect(find.byType(EditProfile), findsOneWidget);

    router.go('/users/$testUsername/share_profile?uid=$testUid');
    await pumpNavFrames(tester);
    expect(find.byType(ShareProfile), findsOneWidget);

    router.go('/users/$testUsername/user_settings?uid=$testUid');
    await pumpNavFrames(tester);
    expect(find.byType(UserSettings), findsOneWidget);
  });

  testWidgets('profile stack: settings children routes', (tester) async {
    final container = await pumpNavigationApp(
      tester,
      overrides: signedInNavigationOverrides(),
    );
    final router = goRouter(container);

    router.go('/users/$testUsername/user_settings/change_email?uid=$testUid');
    await pumpNavFrames(tester);
    expect(find.byType(ChangeEmailPage), findsOneWidget);

    router.go(
      '/users/$testUsername/user_settings/change_password?uid=$testUid',
    );
    await pumpNavFrames(tester);
    expect(find.byType(ChangePasswordPage), findsOneWidget);

    router.go('/users/$testUsername/user_settings/blocked_users?uid=$testUid');
    await pumpNavFrames(tester);
    expect(find.byType(BlockedUsersPage), findsOneWidget);
  });
}
