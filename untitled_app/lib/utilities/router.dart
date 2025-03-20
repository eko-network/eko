import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/safe_area.dart';
import 'package:untitled_app/models/users.dart';
import 'package:untitled_app/views/blocked_users_page.dart';
import 'package:untitled_app/views/download_page.dart';
import 'package:untitled_app/views/edit_group_page.dart';
import 'package:untitled_app/views/invalid_session_page.dart';
import 'package:untitled_app/views/login.dart';
import 'package:untitled_app/views/re_auth_page.dart';
import 'package:untitled_app/views/share_profile_page.dart';
import 'package:untitled_app/views/sign_up.dart';
import 'package:untitled_app/views/user_settings.dart';
import '../views/compose_page.dart';
import '../views/feed_page.dart';
import '../views/search_page.dart';
import '../views/profile_page.dart';
import '../views/edit_profile.dart';
import 'router_notifier.dart';
import '../views/navigation_bar.dart';
import '../models/post_handler.dart';
import '../views/other_profile.dart';
import '../views/view_post_page.dart';
import '../views/profile_picture_detail.dart';
import '../views/welcome.dart';
import '../views/followers.dart';
import '../views/following.dart';
import '../views/recent_activity.dart';
import '../views/groups_page.dart';
import '../views/create_group_page.dart';
import '../models/group_handler.dart';
import '../custom_widgets/emoji_picker.dart';
import '../views/sub_group_page.dart';
import '../models/group_handler.dart' show Group;
import '../views/auth_action_interface.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../views/view_likes_page.dart';
import '../views/update_required_page.dart';

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
final routerNotifier = RouterNotifier();
final goRouter = GoRouter(
  observers: [
    FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
  ],
  refreshListenable: routerNotifier,
  redirect: routerNotifier.redirect,
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  redirectLimit: 15,
  routes: [
    // GoRoute(
    //   path: '/',
    //   builder: (context, state) {
    //     return const RootPage();
    //   },
    // ),

    GoRoute(
      path: '/profile_picture_detail',
      name: 'profile_picture_detail',
      builder: (context, state) {
        String url = state.extra as String;
        return ProfilePictureDetail(imageURL: url);
      },
    ),

    GoRoute(
        path: '/',
        name: 'root',
        builder: (context, state) {
          return const WelcomePage();
        },
        routes: [
          GoRoute(
            path: 'signup',
            name: 'signup',
            builder: (context, state) {
              return const AppSafeArea(child: SignUp());
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
        return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorFeedKey,
          routes: [
            GoRoute(
              path: '/feed',
              name: 'feed',
              pageBuilder: (context, state) {
                bool reload = false;
                if (state.extra is bool) reload = state.extra as bool;
                return NoTransitionPage(
                  child: FeedPage(
                    rebuild: reload,
                  ),
                );
              },
              routes: [
                GoRoute(
                  path: 'sub_profile/:id',
                  name: 'sub_profile',
                  builder: (context, state) {
                    AppUser? user = state.extra as AppUser?;
                    String id = state.pathParameters["id"]!;
                    return OtherProfile(user: user, id: id);
                  },
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
                  builder: (context, state) {
                    Post? post = state.extra as Post?;
                    String id = state.pathParameters["id"]!;
                    return ViewPostPage(post: post, id: id);
                  },
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
                //return const NoTransitionPage(child: GroupsPage());
                bool? reload;
                if (state.extra is bool) {
                  reload = state.extra as bool?;
                }
                return NoTransitionPage(
                  child: reload == null
                      ? const GroupsPage()
                      : GroupsPage(
                          reload: reload,
                        ),
                );
              },
              routes: [
                GoRoute(
                    path: 'sub_group/:id',
                    name: 'sub_group',
                    builder: (context, state) {
                      Group? group = state.extra as Group?;
                      String id = state.pathParameters["id"]!;
                      return SubGroupPage(group: group, id: id);
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
              // FIXME
              // onExit: (context) {
              //   locator<NavBarController>().enable();
              //   return true;
              // },
              path: '/compose',
              name: 'compose',
              pageBuilder: (context, state) {
                final Group? group = state.extra as Group?;
                //if (args != null) print(args[0]);
                return NoTransitionPage(
                  child: ComposePage(group: group),
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
                  // FIXME
                  // onExit: (context) {
                  //   locator<NavBarController>().enable();
                  //   return true;
                  // },
                  path: 'edit_profile',
                  name: 'edit_profile',
                  builder: (context, state) => const EditProfile(),
                ),
                GoRoute(
                  // FIXME
                    // onExit: (context) {
                    //   locator<NavBarController>().enable();
                    //   return true;
                    // },
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
                      AppUser user = state.extra as AppUser;
                      return Followers(user: user);
                    }),
                GoRoute(
                  path: 'following',
                  name: 'following',
                  builder: (context, state) {
                    AppUser user = state.extra as AppUser;
                    return Following(user: user);
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
