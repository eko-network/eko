import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/safe_area.dart';
import 'package:untitled_app/models/notification_helper.dart';
import 'package:untitled_app/types/user.dart';
import 'package:untitled_app/views/blocked_users_page.dart';
import 'package:untitled_app/views/download_page.dart';
import 'package:untitled_app/views/edit_group_page.dart';
import 'package:untitled_app/views/camera_page.dart';
import 'package:untitled_app/views/invalid_session_page.dart';
import 'package:untitled_app/views/login.dart';
import 'package:untitled_app/views/re_auth_page.dart';
import 'package:untitled_app/views/share_profile_page.dart';
import 'package:untitled_app/views/sign_up.dart';
import 'package:untitled_app/views/user_settings.dart';
import 'package:untitled_app/views/compose_page.dart';
import 'package:untitled_app/views/feed_page.dart';
import 'package:untitled_app/views/search_page.dart';
import 'package:untitled_app/views/profile_page.dart';
import 'package:untitled_app/views/edit_profile.dart';
import 'package:untitled_app/views/navigation_bar.dart';
import 'package:untitled_app/views/other_profile.dart';
import 'package:untitled_app/views/view_post_page.dart';
import 'package:untitled_app/views/profile_picture_detail.dart';
import 'package:untitled_app/views/welcome.dart';
import 'package:untitled_app/views/followers.dart';
import 'package:untitled_app/views/following.dart';
import 'package:untitled_app/views/recent_activity.dart';
import 'package:untitled_app/views/groups_page.dart';
import 'package:untitled_app/views/create_group_page.dart';
import 'package:untitled_app/models/group_handler.dart';
import 'package:untitled_app/custom_widgets/emoji_picker.dart';
import 'package:untitled_app/views/sub_group_page.dart';
import 'package:untitled_app/models/group_handler.dart' show Group;
import 'package:untitled_app/views/auth_action_interface.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:untitled_app/views/view_likes_page.dart';
import 'package:untitled_app/views/update_required_page.dart';
import 'package:untitled_app/widgets/gifs.dart';
import 'package:untitled_app/widgets/require_auth.dart';
import 'package:untitled_app/widgets/require_no_auth.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorFeedKey = GlobalKey<NavigatorState>(debugLabel: 'Feed');
final _shellNavigatorSearchKey =
    GlobalKey<NavigatorState>(debugLabel: 'Search');
final _shellNavigatorComposeKey =
    GlobalKey<NavigatorState>(debugLabel: 'Compose');
final _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'Profile');
final _shellNavigatorGroupsKey =
    GlobalKey<NavigatorState>(debugLabel: 'Groups');
final goRouter = GoRouter(
  observers: [
    FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
  ],
  initialLocation: '/feed',
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  redirectLimit: 15,
  routes: [
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
            path: 'auth',
            name: 'auth',
            builder: (context, state) {
              final url = state.uri.queryParameters;

              return AppSafeArea(child: AuthActionInterface(urlData: url));
            },
          ),
          GoRoute(
            path: 'login',
            name: 'login',
            builder: (context, state) {
              return const AppSafeArea(child: LoginPage());
            },
          ),
          GoRoute(
            path: 'download',
            name: 'download',
            builder: (context, state) {
              return const AppSafeArea(child: DownloadPage());
            },
          ),
          GoRoute(
            path: 'update',
            name: 'update',
            builder: (context, state) {
              return const AppSafeArea(child: UpdateRequiredPage());
            },
          ),
          GoRoute(
            path: 'invalid_session',
            name: 'invalid_session',
            builder: (context, state) {
              return const AppSafeArea(child: InvalidSessionPage());
            },
          ),
        ]),
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
                    navigationShell: navigationShell),
              ),
            ));
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorFeedKey,
          routes: [
            GoRoute(
              path: '/feed',
              name: 'feed',
              pageBuilder: (context, state) {
                return NoTransitionPage(
                  child: FeedPage(),
                );
              },
              routes: [
                GoRoute(
                  path: 'sub_profile/:id',
                  name: 'sub_profile',
                  builder: (context, state) =>
                      OtherProfile(uid: state.pathParameters['id']!),
                ),
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
                  builder: (context, state) =>
                      ViewPostPage(id: state.pathParameters['id']!),
                  routes: [
                    GoRoute(
                      path: 'likes',
                      name: 'likes',
                      builder: (context, state) {
                        String postId = state.extra as String;
                        return ViewLikesPage(
                          postId: postId,
                        );
                      },
                    ),
                    GoRoute(
                      path: 'dislikes',
                      name: 'dislikes',
                      builder: (context, state) {
                        String postId = state.extra as String;
                        return ViewLikesPage(
                          postId: postId,
                          dislikes: true,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorGroupsKey,
          routes: [
            GoRoute(
              path: '/groups',
              name: 'groups',
              pageBuilder: (context, state) {
                return NoTransitionPage(
                  child: GroupsPage(),
                );
              },
              routes: [
                GoRoute(
                    path: 'sub_group/:id',
                    name: 'sub_group',
                    builder: (context, state) {
                      String id = state.pathParameters['id']!;
                      return SubGroupPage(id: id);
                    },
                    routes: [
                      GoRoute(
                          path: 'edit_group',
                          name: 'edit_group',
                          pageBuilder: (context, state) {
                            Group? group = state.extra as Group;
                            return NoTransitionPage(
                              child: EditGroupPage(group: group),
                            );
                          }),
                    ]),
                GoRoute(
                  path: 'create_group',
                  name: 'create_group',
                  builder: (context, state) => const CreateGroupPage(),
                  routes: [
                    GoRoute(
                      path: 'pick_emoji',
                      name: 'pick_emoji',
                      pageBuilder: (context, state) {
                        return NoTransitionPage(
                          child: EmojiSelector(
                              onPressed: state.extra! as void Function(String)),
                        );
                      },
                      //builder: (context, state) => EmojiSelector(onPressed: state.extra! as void Function(String)),
                    )
                  ],
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
                final String? id = state.uri.queryParameters['id'];
                return NoTransitionPage(
                  child: ComposePage(groupId: id),
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSearchKey,
          routes: [
            GoRoute(
              path: '/search',
              name: 'search',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SearchPage(),
              ),
              routes: [
                GoRoute(
                  path: 'camera',
                  name: 'camera',
                  builder: (context, state) => const CameraPage(),
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

                          final tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
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
          navigatorKey: _shellNavigatorProfileKey,
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfilePage(),
              ),
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
                        path: 're_auth',
                        name: 're_auth',
                        builder: (context, state) => const ReAuthPage(),
                      ),
                      GoRoute(
                        path: 'blocked_users',
                        name: 'blocked_users',
                        builder: (context, state) => const BlockedUsersPage(),
                      ),
                    ]),
                GoRoute(
                    path: 'followers',
                    name: 'followers',
                    builder: (context, state) {
                      UserModel user = state.extra as UserModel;
                      return Followers(uid: user.uid);
                    }),
                GoRoute(
                  path: 'following',
                  name: 'following',
                  builder: (context, state) {
                    UserModel user = state.extra as UserModel;
                    return Following(uid: user.uid);
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
