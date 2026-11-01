import 'dart:async';

import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/comment_list_provider.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/following_feed_provider.dart';
import 'package:eko_app/providers/new_feed_provider.dart';
import 'package:eko_app/providers/popular_feed_provider.dart';
import 'package:eko_app/providers/pool_providers.dart';
import 'package:eko_app/providers/profile_post_list_provider.dart';
import 'package:eko_app/providers/follow_info_provider.dart';
import 'package:eko_app/providers/pending_deep_link_provider.dart';
import 'package:eko_app/providers/post_provider.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:eko_app/types/auth.dart';
import 'package:eko_app/types/current_user.dart';
import 'package:eko_app/types/follow_info.dart';
import 'package:eko_app/types/post.dart';
import 'package:eko_app/types/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/utilities/router.dart';
import 'app_harness.dart';

/// Stable ids for navigation tests (must match query `uid` on profile routes).
const testUid = 'test-uid-1';
const testUsername = 'testuser';

/// Post id used for `/feed/post/:id` tests (pool must be seeded).
const testPostId = 42;

/// Call from each test file's `setUpAll`.
Future<void> ensureNavigationTestPrefs() async {
  await ensureAppHarnessReady();
}

/// Minimal [PostModel] for [postPoolProvider] so [postProvider] never hits RPC.
PostModel get testNavigationPost => PostModel(
  uid: 'author-uid',
  id: testPostId,
  createdAt: '2020-01-01T00:00:00.000Z',
);

UserModel get testNavigationUser => UserModel(
  name: 'Tester',
  username: testUsername,
  profilePicture: '',
  bio: '',
  uid: testUid,
  isVerified: false,
  shareOnlineStatus: false,
);

class FakeSignedOutAuth extends Auth {
  @override
  Future<AuthModel> build() async {
    return AuthModel.signedOut();
  }
}

class FakeSignedInAuth extends Auth {
  @override
  Future<AuthModel> build() async {
    return AuthModel(uid: testUid);
  }
}

/// Avoids [PendingDeepLink.set] during GoRouter redirect (Riverpod forbids
/// modifying providers while the widget tree is building — breaks tests).
class _FakeFollowInfo extends FollowInfo {
  @override
  Future<FollowInfoModel> build(String uid) async =>
      const FollowInfoModel(followers: 0, following: 0);
}

class _FakeUser extends User {
  @override
  FutureOr<UserModel> build(String uid) {
    if (uid == testUid) return testNavigationUser;
    return testNavigationUser.copyWith(
      uid: uid,
      username: 'author',
      name: 'Author',
    );
  }
}

class _FakePost extends Post {
  @override
  FutureOr<PostModel> build(int id) => testNavigationPost.copyWith(id: id);
}

class FakePendingDeepLink extends PendingDeepLink {
  @override
  String? build() => null;

  @override
  void set(String path) {}

  @override
  String? consume() => null;
}

class FakeSignedInCurrentUser extends CurrentUser {
  @override
  CurrentUserModel build() {
    return CurrentUserModel(user: testNavigationUser);
  }
}

class _EndedNewFeed extends NewFeed {
  @override
  (List<int>, bool) build() => ([], true);

  @override
  Future<void> getter() async {}

  @override
  Future<void> refresh() async {}
}

class _EndedFollowingFeed extends FollowingFeed {
  @override
  (List<int>, bool) build() => ([], true);

  @override
  Future<void> getter() async {}

  @override
  Future<void> refresh() async {}
}

class _EndedPopularFeed extends PopularFeed {
  @override
  (List<int>, bool) build() => ([], true);

  @override
  Future<void> getter() async {}

  @override
  Future<void> refresh() async {}
}

class _FakeNeedsProfileSetup extends NeedsProfileSetupNotifier {
  _FakeNeedsProfileSetup(this._value);
  final bool _value;

  @override
  bool build() => _value;
}

class _EmptyEndedProfilePosts extends ProfilePostListNotifier {
  @override
  ProfilePostListState build() => ([], true);

  @override
  Future<void> getter() async {}

  @override
  Future<void> refresh() async {}
}

class _EmptyEndedOtherProfilePosts extends OtherProfilePostListNotifier {
  _EmptyEndedOtherProfilePosts(super.uid);

  @override
  ProfilePostListState build() => ([], true);

  @override
  Future<void> getter() async {}

  @override
  Future<void> refresh() async {}
}

class _EmptyEndedCommentList extends CommentList {
  @override
  (List<int>, bool) build(int postId) => ([], true);

  @override
  Future<void> getter(int postId) async {}

  @override
  Future<void> refresh() async {}
}

List<Override> signedInNavigationOverrides({bool needsProfileSetup = false}) {
  return [
    pendingDeepLinkProvider.overrideWith(FakePendingDeepLink.new),
    authProvider.overrideWith(FakeSignedInAuth.new),
    currentUserProvider.overrideWith(FakeSignedInCurrentUser.new),
    needsProfileSetupProvider.overrideWith(
      () => _FakeNeedsProfileSetup(needsProfileSetup),
    ),
    newFeedProvider.overrideWith(_EndedNewFeed.new),
    followingFeedProvider.overrideWith(_EndedFollowingFeed.new),
    popularFeedProvider.overrideWith(_EndedPopularFeed.new),
    profilePostListProvider.overrideWith(_EmptyEndedProfilePosts.new),
    otherProfilePostListProvider(
      testUid,
    ).overrideWith(() => _EmptyEndedOtherProfilePosts(testUid)),
    commentListProvider(testPostId).overrideWith(_EmptyEndedCommentList.new),
    postProvider(testPostId).overrideWith(_FakePost.new),
    userProvider(testUid).overrideWith(_FakeUser.new),
    userProvider('author-uid').overrideWith(_FakeUser.new),
    followInfoProvider(testUid).overrideWith(_FakeFollowInfo.new),
    followInfoProvider('author-uid').overrideWith(_FakeFollowInfo.new),
  ];
}

List<Override> signedOutNavigationOverrides() {
  return [
    pendingDeepLinkProvider.overrideWith(FakePendingDeepLink.new),
    authProvider.overrideWith(FakeSignedOutAuth.new),
  ];
}

void seedTestPost(ProviderContainer container) {
  container.read(postPoolProvider).put(testNavigationPost);
}

void seedTestUser(ProviderContainer container) {
  container.read(userPoolProvider).put(testNavigationUser);
}

/// Pumps [MyApp] with a fresh [ProviderContainer] and common overrides.
Future<ProviderContainer> pumpNavigationApp(
  WidgetTester tester, {
  List<Override> overrides = const [],
}) async {
  return pumpAppHarness(tester, overrides: overrides);
}

Uri currentRouterUri(ProviderContainer container) {
  return container.read(goRouterProvider).routeInformationProvider.value.uri;
}

GoRouter goRouter(ProviderContainer container) =>
    container.read(goRouterProvider);

/// Bounded post-navigation pump (avoids [pumpAndSettle] hanging on animations).
Future<void> pumpNavFrames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}
