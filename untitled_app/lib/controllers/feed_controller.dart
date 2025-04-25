import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/models/notification_service.dart';
import 'package:untitled_app/models/uri_launcher.dart';
import 'package:untitled_app/models/version_control.dart';
import 'package:untitled_app/utilities/locator.dart';
import '../models/current_user.dart';
import 'package:go_router/go_router.dart';
import '../models/post_handler.dart';
import '../custom_widgets/controllers/pagination_controller.dart'
    show PaginationGetterReturn;
import '../custom_widgets/warning_dialog.dart';

showOverlayNote(BuildContext context, RemoteMessage message) {
  showOverlayNotification((context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: SafeArea(
        child: ListTile(
          leading: SizedBox.fromSize(
            size: const Size(40, 40),
            child: ClipOval(
                child: Container(
              color: Colors.black,
            )),
          ),
          title: Text(message.notification?.title ?? 'New Notification'),
          subtitle: Text(message.notification?.body ?? ''),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              OverlaySupportEntry.of(context)?.dismiss();
            },
          ),
          onTap: () async {
            await NotificationService().inAppPostNotification(context, message);
            OverlaySupportEntry.of(context)?.dismiss();
          },
        ),
      ),
    );
  }, duration: const Duration(milliseconds: 4000));
}

class FeedController extends ChangeNotifier {
  int index = 0;
  bool rebuild;
  Query<Map<String, dynamic>>? query;
  // FirebaseFirestore.instance
  //     .collection("posts")
  //     .where("tags", arrayContains: "public")
  //     .orderBy('time', descending: true);
  final BuildContext context;
  bool newActivity = false;

  FeedController({required this.context, required this.rebuild}) {
    
    if (checkLoggedIn()) {
      NotificationService notificationService = NotificationService();
      if (rebuild) {
        rebuildFunction();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        
        if (locator<Version>().lessThanTarget) {
          showMyDialog(
              AppLocalizations.of(context)!.updateAvailable,
              '',
              [
                AppLocalizations.of(context)!.ok,
                AppLocalizations.of(context)!.update
              ],
              [context.pop, UriLauncher.launchCorrectStore],
              context);
        }
      });
      checkNewActivity();

      // Handling the initial message received when the app is launched from dead (killed state)
      // When the app is killed and a new notification arrives when user clicks on it
      // It gets the data to which screen to open
      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          notificationService.postNotification(context, message);
        }
      });
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        notificationService.postNotification(context, message);
        rebuildFunction();
      });
      //copyArray();
    }
  }

  bool checkLoggedIn() {
    if (locator<CurrentUser>().getUID() == '') {
      return false;
    }
    return true;
  }

  // void copyArray() async {
  //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //   final CollectionReference users = _firestore.collection('users');

  //   final QuerySnapshot allUsersSnapshot = await users.get();
  //   final List<DocumentSnapshot> allUsers = allUsersSnapshot.docs;

  //   for (var user in allUsers) {
  //     final String id = user.id;
  //     print("id");
  //     final DocumentSnapshot likesDoc =
  //         await users.doc(id).collection('arrays').doc('likes').get();
  //     final List<String> friends = List<String>.from(likesDoc.get('likes'));

  //     await users.doc(id).update({'profileData.likedPosts': friends});
  //   }
  // }

  void checkNewActivity() {
    newActivity = locator<CurrentUser>().newActivity;
    // notifyListeners();
    //  print(newActivity);
  }

  void rebuildFunction() {
    notifyListeners();
  }

  void onTabPressed(int newIndex) {
    index = newIndex;
    getQueryFromIndex();
    notifyListeners();
  }

  void onNotificationButtonPressed() {
    context.push('/feed/recent').then((v) async {
      checkNewActivity();
      notifyListeners();
    });
  }

  void onRefresh() async {
    if (index == 0) {
      locator<PostsHandling>().feedChunks.clear();
    }

    await locator<CurrentUser>().readCurrentUserData();
  }

  Future<PaginationGetterReturn> getPosts(dynamic time) {
    return locator<PostsHandling>().getFeedPosts(time, query);
  }

  dynamic getTimeFromPost(dynamic post) {
    if (index != 2) {
      return locator<PostsHandling>().getTimeFromPost(post);
    } else {
      return (post as Post).likes;
    }
  }

  void getQueryFromIndex() {
    switch (index) {
      case 0:
        query = null;
        break;

      case 1:
        query = FirebaseFirestore.instance
            .collection('posts')
            .where('tags', arrayContains: 'public')
            .orderBy('time', descending: true);
        break;
      case 2:
        query = FirebaseFirestore.instance
            .collection('posts')
            .where('tags', arrayContains: 'public')
            .orderBy('likes', descending: true);
        break;
      // case 3:
      //   query = FirebaseFirestore.instance
      //       .collection("posts")
      //       .where("tags", arrayContains: "public")
      //       .orderBy('time', descending: false);
      //   break;
      default:
        query = null;
        break;
    }
  }
}
