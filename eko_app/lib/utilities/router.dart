import 'package:cross_file/cross_file.dart' show XFile;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/widgets/scaffolds/app_safe_area.dart';
import 'package:eko_app/interfaces/notification_helper.dart';
import 'package:eko_app/views/blocked_users_page.dart';
import 'package:eko_app/views/change_email_page.dart';
import 'package:eko_app/views/change_password_page.dart';
import 'package:eko_app/views/download_page.dart';
import 'package:eko_app/views/camera_page.dart';
import 'package:eko_app/views/edit_picture.dart';
import 'package:eko_app/views/login.dart';
import 'package:eko_app/views/share_profile_page.dart';
import 'package:eko_app/views/sign_up.dart';
import 'package:eko_app/views/user_settings.dart';
import 'package:eko_app/views/compose_page.dart';
import 'package:eko_app/views/feed_page.dart';
import 'package:eko_app/messenger/views/adaptive_chat_layout.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/views/search_page.dart';
import 'package:eko_app/views/edit_profile.dart';
import 'package:eko_app/widgets/scaffolds/navigation_bar.dart';
import 'package:eko_app/views/profile_page.dart';
import 'package:eko_app/views/view_post_page.dart';
import 'package:eko_app/views/profile_picture_detail.dart';
import 'package:eko_app/views/welcome.dart';
import 'package:eko_app/views/google_setup_page.dart';
import 'package:eko_app/views/followers.dart';
import 'package:eko_app/views/following.dart';
import 'package:eko_app/views/recent_activity.dart';
import 'package:eko_app/views/view_likes_page.dart';
import 'package:eko_app/widgets/posts/gifs.dart';
import 'package:eko_app/widgets/scaffolds/require_auth.dart';
import 'package:eko_app/widgets/scaffolds/require_no_auth.dart';
import 'package:eko_app/views/profile_redirect_page.dart';

final _shellNavigatorFeedKey = GlobalKey<NavigatorState>(debugLabel: 'Feed');
final _shellNavigatorMessagesKey = GlobalKey<NavigatorState>(
  debugLabel: 'Messages',
);
final _shellNavigatorComposeKey = GlobalKey<NavigatorState>(
  debugLabel: 'Compose',
);
final _shellNavigatorSearchKey = GlobalKey<NavigatorState>(
  debugLabel: 'Search',
);
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(
  debugLabel: 'Profile',
);

class GoRouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/feed',
    navigatorKey: NotificationHelper.navigatorKey,
    debugLogDiagnostics: kDebugMode,
    routes: [
      GoRoute(
        path: '/google_setup',
        name: 'google_setup',
        builder: (context, state) =>
            const AppSafeArea(child: GoogleSetupPage()),
      ),
      GoRoute(
        path: '/profile_picture_detail/:id',
        name: 'profile_picture_detail',
        builder: (context, state) {
          return ProfilePictureDetail(uid: state.pathParameters['id']!);
        },
      ),
      GoRoute(
        path: '/',
        name: 'root',
        builder: (context, state) {
          return const RequireNoAuth(child: WelcomePage());
        },
        routes: [
          GoRoute(
            path: 'signup',
            name: 'signup',
            builder: (context, state) {
              return const RequireNoAuth(child: AppSafeArea(child: SignUp()));
            },
          ),
          GoRoute(
            path: 'login',
            name: 'login',
            builder: (context, state) {
              return const RequireNoAuth(
                child: AppSafeArea(child: LoginPage()),
              );
            },
          ),
          GoRoute(
            path: 'download',
            name: 'download',
            builder: (context, state) {
              return const AppSafeArea(child: DownloadPage());
            },
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return PopScope(
            canPop: navigationShell.currentIndex == 0,
            onPopInvokedWithResult: (bool didPop, Object? result) {
              if (didPop) return;
              navigationShell.goBranch(0);
            },
            child: NotificationHandler(
              child: RequireAuth(
                child: ScaffoldWithNestedNavigation(
                  navigationShell: navigationShell,
                ),
              ),
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorFeedKey,
            routes: [
              GoRoute(
                path: '/feed',
                name: 'feed',
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: FeedPage());
                },
                routes: [
                  GoRoute(
                    path: 'recent',
                    name: 'recent',
                    //name: 'post_screen',
                    builder: (context, state) {
                      return const RecentActivity();
                    },
                  ),
                  GoRoute(
                    path: 'post/:id',
                    name: 'post',
                    builder: (context, state) {
                      final id = int.tryParse(state.pathParameters['id'] ?? '');
                      if (id == null) {
                        return const FeedPage();
                      }
                      return ViewPostPage(id: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'likes',
                        name: 'likes',
                        builder: (context, state) {
                          final id = int.tryParse(
                            state.pathParameters['id'] ?? '',
                          );
                          if (id == null) {
                            return const FeedPage();
                          }
                          return ViewPostLikesPage(postId: id);
                        },
                      ),
                      GoRoute(
                        path: 'dislikes',
                        name: 'dislikes',
                        builder: (context, state) {
                          final id = int.tryParse(
                            state.pathParameters['id'] ?? '',
                          );
                          if (id == null) {
                            return const FeedPage();
                          }
                          return ViewPostLikesPage(postId: id, dislikes: true);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'comment/:id/likes',
                    name: 'comment_likes',
                    builder: (context, state) {
                      final id = int.tryParse(state.pathParameters['id'] ?? '');
                      if (id == null) {
                        return const FeedPage();
                      }
                      return ViewCommentLikesPage(commentId: id);
                    },
                  ),
                  GoRoute(
                    path: 'comment/:id/dislikes',
                    name: 'comment_dislikes',
                    builder: (context, state) {
                      final id = int.tryParse(state.pathParameters['id'] ?? '');
                      if (id == null) {
                        return const FeedPage();
                      }
                      return ViewCommentLikesPage(
                        commentId: id,
                        dislikes: true,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorMessagesKey,
            routes: [
              GoRoute(
                path: '/messages',
                name: 'messages',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: MessagesGaurd(child: AdaptiveChat()),
                ),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'message_thread',
                    pageBuilder: (context, state) {
                      final id = int.tryParse(state.pathParameters['id'] ?? '');
                      final isWide =
                          MediaQuery.of(context).size.width >=
                          c.messengerWideScreen;

                      Page<void> buildPage(Widget child) {
                        if (isWide) {
                          return NoTransitionPage(child: child);
                        }
                        return MaterialPage(child: child);
                      }

                      if (id == null) {
                        return buildPage(MessagesGaurd(child: AdaptiveChat()));
                      }
                      return buildPage(
                        MessagesGaurd(child: AdaptiveChat(selectedGroupId: id)),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorComposeKey,
            routes: [
              GoRoute(
                path: '/compose',
                name: 'compose',
                pageBuilder: (context, state) {
                  final int? repostId = int.tryParse(
                    state.uri.queryParameters['repostId'] ?? '',
                  );
                  final String? timestamp =
                      state.uri.queryParameters['timestamp'];
                  return NoTransitionPage(
                    child: ComposePage(
                      repostId: repostId,
                      timestamp: timestamp,
                    ),
                  );
                },
                routes: [
                  if (!kIsWeb)
                    GoRoute(
                      path: '/camera',
                      name: 'camera',
                      builder: (context, state) => const CameraPage(),
                    ),
                  if (!kIsWeb)
                    GoRoute(
                      path: '/edit_picture',
                      name: 'edit_picture',
                      builder: (context, state) {
                        final file = state.extra as XFile;
                        return EditPicture(picture: file);
                      },
                    ),
                  GoRoute(
                    path: '/gif',
                    name: 'gif',
                    pageBuilder: (context, state) {
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: GifSearchSection(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              const begin = Offset(0.0, 1.0);
                              const end = Offset.zero;
                              const curve = Curves.easeOut;

                              final tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));
                              final offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSearchKey,
            routes: [
              GoRoute(
                path: '/search',
                name: 'search',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SearchPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProfileRedirect()),
              ),
              GoRoute(
                path: '/users/:username',
                name: 'user_profile',
                builder: (context, state) {
                  final username = state.pathParameters['username']!;
                  final uid = state.uri.queryParameters['uid'];
                  return ProfilePage(username: username, uid: uid);
                },
                routes: [
                  GoRoute(
                    path: 'share_profile',
                    name: 'share_profile',
                    builder: (context, state) => const ShareProfile(),
                  ),
                  GoRoute(
                    path: 'edit_profile',
                    name: 'edit_profile',
                    builder: (context, state) => const EditProfile(),
                  ),
                  GoRoute(
                    path: 'user_settings',
                    name: 'user_settings',
                    builder: (context, state) => const UserSettings(),
                    routes: [
                      GoRoute(
                        path: 'blocked_users',
                        name: 'blocked_users',
                        builder: (context, state) => const BlockedUsersPage(),
                      ),
                      GoRoute(
                        path: 'change_email',
                        name: 'change_email',
                        builder: (context, state) => const ChangeEmailPage(),
                      ),
                      GoRoute(
                        path: 'change_password',
                        name: 'change_password',
                        builder: (context, state) => const ChangePasswordPage(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'followers',
                    name: 'followers',
                    builder: (context, state) {
                      final username = state.pathParameters['username']!;
                      final uid = state.uri.queryParameters['uid'];
                      return Followers(username: username, uid: uid);
                    },
                  ),
                  GoRoute(
                    path: 'following',
                    name: 'following',
                    builder: (context, state) {
                      final username = state.pathParameters['username']!;
                      final uid = state.uri.queryParameters['uid'];
                      return Following(username: username, uid: uid);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
