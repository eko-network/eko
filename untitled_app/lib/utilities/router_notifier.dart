import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/controllers/bottom_nav_bar_controller.dart';
import 'package:untitled_app/models/presence_manager.dart';
import '../models/version_control.dart';
import 'locator.dart';
import '../models/current_user.dart';

class RouterNotifier extends ChangeNotifier {
  bool loggedIn = false;
  bool validSession = true;
  bool running = false;
  //final routeStream = StreamController<bool>();
  //final databaseController = StreamController<bool>();
  RouterNotifier() {
    init();
  }
  //Timer? _debounce;

  init() {
    FirebaseAuth.instance.authStateChanges().listen((event) {
      if (event != null) {
        loggedIn = true;
        locator<PresenceManager>().verifySession();
      } else {
        loggedIn = false;
        locator<PresenceManager>().unVerifySession();
      }
      notifyListeners();
      // Add event to authController
      //routeStream.add(true);
    });

    FirebaseDatabase.instance
        .ref('/status/${locator<CurrentUser>().getUID()}')
        .onValue
        .listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<Object?, Object?>;
      final oldState = validSession;
      // print(data['online']);
// locator<PresenceManager>().getSessionId()
      if ((data['id'] ?? '') == locator<PresenceManager>().getSessionId() ||
          !((data['online'] ?? false) as bool)) {
        validSession = true;
      } else {
        validSession = false;
      }
      //print("Old State=$oldState, newState = $validSession");
      if (oldState != validSession) {
        notifyListeners();
      }
    });
  }

  // RouterNotifier() {
  //   FirebaseAuth.instance.authStateChanges().listen((event) {
  //     if (event != null) {
  //       loggedIn = true;
  //       //locator<PresenceManager>().verifySession();
  //     } else {
  //       loggedIn = false;
  //     }
  //     //print('authcahnge $loggedIn');
  //     notifyListeners();
  //   });

  //   FirebaseDatabase.instance
  //       .ref('/status/${locator<CurrentUser>().getUID()}/id')
  //       .onValue
  //       .listen((DatabaseEvent event) {
  //     final data = event.snapshot.value as String?;
  //     //data as String;
  //     print(data == locator<PresenceManager>().getSessionId());
  //     //print();
  //     if (data.toString() == locator<PresenceManager>().getSessionId()) {
  //       print("good");
  //       validSession = true;
  //     } else {
  //       print("bad");
  //       validSession = false;
  //     }
  //     notifyListeners();
  //   });
  // }

  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    final onLoginPage = state.fullPath == '/login';
    final onSignUpPage = state.fullPath == '/signup';
    final onAuthPage = state.fullPath == '/auth';
    final onWelcomePage = state.fullPath == '/';
    final onDownloadPage = state.fullPath == '/download';
    final onFeedPage = state.fullPath == '/feed/post/:id';
    final onProfilePage = state.fullPath == '/feed/sub_profile/:id';
    final onInvalidSession = state.fullPath == '/invalid_session';
    //print('redirect $loggedIn');
    if (locator<Version>().lessThanMin && !kIsWeb) {
      return '/update';
    } else if (onInvalidSession && !loggedIn) {
      return '/';
    } else if (!validSession && !onInvalidSession && loggedIn) {
      return '/invalid_session';
    } else if (validSession && onInvalidSession && loggedIn) {
      if (locator<CurrentUser>().username == '') {
        await locator<CurrentUser>().readCurrentUserData();
      }
      locator<NavBarController>().enable();
      return '/feed';
    } else if (!loggedIn &&
        !(onSignUpPage ||
            onLoginPage ||
            onWelcomePage ||
            onAuthPage ||
            onDownloadPage ||
            onFeedPage ||
            onProfilePage)) {
      return '/';
    } else if (loggedIn && (onLoginPage || onSignUpPage || onWelcomePage)) {
      if (locator<CurrentUser>().username == '') {
        await locator<CurrentUser>().readCurrentUserData();
      }
      locator<NavBarController>().enable();
      return '/feed';
    }
    return null;
  }
}
