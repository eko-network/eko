import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:untitled_app/models/shared_pref_model.dart';
import 'package:untitled_app/utilities/locator.dart';
import '../models/users.dart';
import '../models/post_handler.dart';

class CurrentUser extends AppUser {
  bool newActivity = false;
  bool unreadGroup = false;
  String email = '';
  List<dynamic> likedPosts = [];
  List<dynamic> dislikedPosts = [];
  List<dynamic> blockedUsers = [];
  List<dynamic> blockedBy = [];
  Map<String, int> pollVotes = {};
  bool stateIsVoting = false;
  bool stateIsLiking = false;
  bool stateIsDisliking = false;
  bool stateIsFollowing = false;
  @override
  bool isVerified = false;

  // CurrentUser({this.newActivity = false}) {
  //   // if (likedPosts.isEmpty) {
  //   //   likedPosts = [];
  //   // }
  //   // if (blockedUsers.isEmpty) {
  //   //   blockedUsers = [];
  //   // }
  // }

//gets uid making sure it is current. idk if this is neccesary but it will be easy to remove.
  String getUID() {
    if (uid == '') {
      uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    }
    return uid;
  }

  Future<List<dynamic>> getPeopleWhoBlockedMe() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final user = getUID();
      final querySnapshot = await firestore
          .collection('users')
          .where('blockedUsers', arrayContains: user)
          .get();
      stateIsFollowing = false;
      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> blockUser(String blockedUid) async {
    if (!blockedUsers.contains(blockedUid)) {
      try {
        final firestore = FirebaseFirestore.instance;
        final user = getUID();
        await firestore.collection('users').doc(user).update({
          'blockedUsers': FieldValue.arrayUnion([blockedUid])
        });

        blockedUsers.add(blockedUid);

        removeFollower(blockedUid);
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<bool> unblockUser(String blockedUid) async {
    if (blockedUsers.contains(blockedUid)) {
      try {
        final firestore = FirebaseFirestore.instance;
        final user = getUID();
        await firestore.collection('users').doc(user).update({
          'blockedUsers': FieldValue.arrayRemove([blockedUid])
        });

        blockedUsers.remove(blockedUid);
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<String> signUp(password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      uid = FirebaseAuth.instance.currentUser!.uid;
      // await addFCM();
      return ('success');
    } on FirebaseAuthException catch (e) {
      return (e.code);
    }
  }

  Future<String> signIn(password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      uid = FirebaseAuth.instance.currentUser!.uid;
      return ('success');
    } on FirebaseAuthException catch (e) {
      return (e.code);
    }
  }

  Future<String> forgotPassword(countryCode) async {
    await FirebaseAuth.instance.setLanguageCode(countryCode);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return ('success');
    } on FirebaseAuthException catch (e) {
      return (e.code);
    }
  }

  Future<String> verifyPasswordReset(String code) async {
    try {
      return await FirebaseAuth.instance.verifyPasswordResetCode(code);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<String> resetPassword(String code, String password) async {
    try {
      await FirebaseAuth.instance
          .confirmPasswordReset(code: code, newPassword: password);
      return 'success';
    } on FirebaseAuthException catch (e) {
      return (e.code);
    }
  }

  // Future<void> _readLikedPosts() async {
  //   final user = getUID();
  //   final data = await FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(user)
  //       .collection("arrays")
  //       .doc("likes")
  //       .get();
  //   likedPosts = (data.exists) ? data["likes"] : [];
  // }

  Future<void> readCurrentUserData() async {
    final user = getUID();
    final userData = await readUserData(user); //uses function from parent class
    if (userData != null) {
      email = userData['email'] ?? '';
      likedPosts = userData['profileData']['likedPosts'] ?? [];
      dislikedPosts = userData['profileData']['dislikedPosts'] ?? [];
      blockedUsers = userData['blockedUsers'] ?? [];
      newActivity = userData['newActivity'] ?? false;
      unreadGroup = userData['unreadGroup'] ?? false;
      isVerified = userData['isVerified'] ?? false;
      List<dynamic>? fcmTokens = userData['fcmTokens'];
      blockedBy = await getPeopleWhoBlockedMe();
      pollVotes =
          Map<String, int>.from(userData['profileData']['pollVotes'] ?? {});
      if (fcmTokens == null) {
        addFCM();
      } else if (await getActivityNotification()) {
        List<String> fcmTokens = List<String>.from(userData['fcmTokens'] ?? []);
        final String currentDeviceToken =
            await FirebaseMessaging.instance.getToken() ?? '';
        // check to see if contained in array
        if (!fcmTokens.contains(currentDeviceToken)) {
          fcmTokens.add(currentDeviceToken);
          final DocumentReference userDocRef =
              FirebaseFirestore.instance.collection('users').doc(user);
          // Update the Firestore document with the modified FCM tokens array
          await userDocRef.update({'fcmTokens': fcmTokens});
        }
      }
    }
    //await _readLikedPosts();
  }

//TODO consolidate liking/following functions
  bool checkIsFollowing(String otherUid) {
    return following.contains(otherUid);
  }

  Future<bool> addFollower(String otherUid) async {
    if (!stateIsFollowing) {
      stateIsFollowing = true;
      try {
        final firestore = FirebaseFirestore.instance;
        final user = getUID();
        await Future.wait([
          firestore.collection('users').doc(user).update({
            'profileData.following': FieldValue.arrayUnion([otherUid])
          }),
          firestore.collection('users').doc(otherUid).update({
            'profileData.followers': FieldValue.arrayUnion([user])
          }),
          locator<PostsHandling>().addActivty(
              type: 'follow',
              content: 'Someone followed you',
              path: user,
              user: otherUid)
        ]);

        following.add(otherUid);

        stateIsFollowing = false;
        return true;
      } catch (e) {
        stateIsFollowing = false;
        return false;
      }
    } else {
      return false;
    }
  }

  Future<void> setNewActivity(bool value, {String? uid}) async {
    final firestore = FirebaseFirestore.instance;
    uid ??= getUID();
    newActivity = value;
    await firestore
        .collection('users')
        .doc(uid)
        .set({'newActivity': value}, SetOptions(merge: true));
  }

  Future<void> setUnreadGroup(bool value, {String? uid}) async {
    final firestore = FirebaseFirestore.instance;
    uid ??= getUID();
    unreadGroup = value;
    await firestore
        .collection('users')
        .doc(uid)
        .set({'unreadGroup': value}, SetOptions(merge: true));
  }

  Future<bool> removeFollower(String otherUid) async {
    if (!stateIsFollowing) {
      stateIsFollowing = true;
      try {
        final firestore = FirebaseFirestore.instance;
        final user = getUID();
        await Future.wait([
          firestore.collection('users').doc(user).update({
            'profileData.following': FieldValue.arrayRemove([otherUid])
          }),
          firestore.collection('users').doc(otherUid).update({
            'profileData.followers': FieldValue.arrayRemove([user])
          })
        ]);

        following.remove(otherUid);
        stateIsFollowing = false;
        return true;
      } catch (e) {
        stateIsFollowing = false;
        return false;
      }
    } else {
      return false;
    }
  }

  bool checkIsDisliked(String postID) {
    return dislikedPosts.contains(postID);
  }

  bool checkIsLiked(String postID) {
    return likedPosts.contains(postID);
  }

  int? checkPollVote(String postId) {
    return pollVotes[postId];
  }

  Future<bool> addLike(String postId, String? commentId) async {
    if (!stateIsLiking) {
      stateIsLiking = true;
      try {
        final firestore = FirebaseFirestore.instance;
        final user = getUID();
        await Future.wait([
          firestore.collection('users').doc(user).update({
            'profileData.likedPosts':
                FieldValue.arrayUnion([commentId ?? postId])
          }),
          (commentId == null)
              ? firestore
                  .collection('posts')
                  .doc(postId)
                  .update({'likes': FieldValue.increment(1)})
              : firestore
                  .collection('posts')
                  .doc(postId)
                  .collection('comments')
                  .doc(commentId)
                  .update({'likes': FieldValue.increment(1)})
        ]);

        if (commentId == null) {
          likedPosts.add(postId);
        } else {
          likedPosts.add(commentId);
        }

        stateIsLiking = false;
        return true;
      } catch (e) {
        stateIsLiking = false;
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> addDislike(String postId, String? commentId) async {
    if (!stateIsDisliking) {
      stateIsDisliking = true;
      try {
        final firestore = FirebaseFirestore.instance;
        final user = getUID();
        await Future.wait([
          firestore.collection('users').doc(user).update({
            'profileData.dislikedPosts':
                FieldValue.arrayUnion([commentId ?? postId])
          }),
          (commentId == null)
              ? firestore
                  .collection('posts')
                  .doc(postId)
                  .update({'dislikes': FieldValue.increment(1)})
              : firestore
                  .collection('posts')
                  .doc(postId)
                  .collection('comments')
                  .doc(commentId)
                  .update({'dislikes': FieldValue.increment(1)})
        ]);

        if (commentId == null) {
          dislikedPosts.add(postId);
        } else {
          dislikedPosts.add(commentId);
        }

        stateIsDisliking = false;
        return true;
      } catch (e) {
        stateIsDisliking = false;
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> removeLike(String postId, String? commentId) async {
    if (!stateIsLiking) {
      stateIsLiking = true;
      try {
        final firestore = FirebaseFirestore.instance;
        final user = getUID();
        await Future.wait([
          firestore.collection('users').doc(user).update({
            'profileData.likedPosts':
                FieldValue.arrayRemove([commentId ?? postId])
          }),
          (commentId == null)
              ? firestore
                  .collection('posts')
                  .doc(postId)
                  .update({'likes': FieldValue.increment(-1)})
              : firestore
                  .collection('posts')
                  .doc(postId)
                  .collection('comments')
                  .doc(commentId)
                  .update({'likes': FieldValue.increment(-1)})
        ]);

        if (commentId == null) {
          likedPosts.remove(postId);
        } else {
          likedPosts.remove(commentId);
        }

        stateIsLiking = false;
        return true;
      } catch (e) {
        stateIsLiking = false;
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> removeDislike(String postId, String? commentId) async {
    if (!stateIsDisliking) {
      stateIsDisliking = true;
      try {
        final firestore = FirebaseFirestore.instance;
        final user = getUID();
        await Future.wait([
          firestore.collection('users').doc(user).update({
            'profileData.dislikedPosts':
                FieldValue.arrayRemove([commentId ?? postId])
          }),
          (commentId == null)
              ? firestore
                  .collection('posts')
                  .doc(postId)
                  .update({'dislikes': FieldValue.increment(-1)})
              : firestore
                  .collection('posts')
                  .doc(postId)
                  .collection('comments')
                  .doc(commentId)
                  .update({'dislikes': FieldValue.increment(-1)})
        ]);

        if (commentId == null) {
          dislikedPosts.remove(postId);
        } else {
          dislikedPosts.remove(commentId);
        }

        stateIsDisliking = false;
        return true;
      } catch (e) {
        stateIsDisliking = false;
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> addPollVote(String postId, int optionIndex) async {
    if (!stateIsVoting) {
      stateIsVoting = true;
      try {
        final firestore = FirebaseFirestore.instance;
        final user = getUID();

        await Future.wait([
          // Update user's pollVotes in Firestore
          firestore.collection('users').doc(user).update({
            'profileData.pollVotes.$postId': optionIndex,
          }),
          // Update poll vote count in the post document
          firestore
              .collection('posts')
              .doc(postId)
              .update({'pollVoteCounts.$optionIndex': FieldValue.increment(1)}),
        ]);

        // Update local state
        pollVotes[postId] = optionIndex;

        stateIsVoting = false;
        return true;
      } catch (e) {
        stateIsVoting = false;
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> removePollVote(String postId) async {
    if (!stateIsVoting) {
      stateIsVoting = true;
      try {
        final firestore = FirebaseFirestore.instance;
        final user = getUID();

        // Get the current vote option
        final currentVoteOption = pollVotes[postId];

        await Future.wait([
          // Update user's pollVotes in Firestore
          firestore.collection('users').doc(user).update({
            'profileData.pollVotes.$postId': FieldValue.delete(),
          }),
          // Update poll vote count in the post document
          firestore.collection('posts').doc(postId).update(
              {'pollVoteCounts.$currentVoteOption': FieldValue.increment(-1)}),
        ]);

        // Remove from local state
        pollVotes.remove(postId);

        stateIsVoting = false;
        return true;
      } catch (e) {
        stateIsVoting = false;
        return false;
      }
    } else {
      return false;
    }
  }

  Future<File?> setPreviewProfileImage(
      {ImageSource source = ImageSource.gallery,
      int imageQuality = 100,
      imageHeight = 300.0}) async {
    final ImagePicker imagePicker = ImagePicker();
    final ImageCropper imageCropper = ImageCropper();
    XFile? pickedFile;
    CroppedFile? cropedFile;
    pickedFile = await imagePicker.pickImage(
      source: source,
    ); //maxHeight: imageHeight,imageQuality: imageQuality
    if (pickedFile == null) {
      return null;
    }

    cropedFile = await imageCropper.cropImage(
        sourcePath: pickedFile.path,
        // FIXME
        // cropStyle: CropStyle.circle,
        maxHeight: 300,
        maxWidth: 300,
        aspectRatio: const CropAspectRatio(ratioX: 150, ratioY: 150),
        uiSettings: [
          AndroidUiSettings(
            showCropGrid: false,
            hideBottomControls: true,
          ),
          IOSUiSettings() //TODO make this look good
        ]);
    if (cropedFile == null) {
      return null;
    }
    // if (await _uploadProfilePicture(File(cropedFile.path)) == "success") {
    //   return "success";
    // }
    return File(cropedFile.path);
  }

  Future<String> uploadProfilePicture(File profile) async {
    final firestore = FirebaseFirestore.instance;
    final user = getUID();
    await FirebaseStorage.instance
        .ref()
        .child('profile_pictures/$user/profile.jpg')
        .putFile(profile);
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures/$user/profile.jpg');

      profilePicture = await ref.getDownloadURL();

      firestore
          .collection('users')
          .doc(user)
          .update({'profileData.profilePicture': profilePicture});
      return 'success';
    } catch (e) {
      return 'fail';
    }
  }

  // TODO: This will eventually need to upload all the data that changed as profile editing gets larger
  // Im thinking a 'save' and 'cancel' button pops up on the app bar is an edit is detected
  Future<String> uploadProfileBio(String bio) async {
    final firestore = FirebaseFirestore.instance;
    final user = getUID();
    try {
      await firestore
          .collection('users')
          .doc(user)
          .update({'profileData.bio': bio});
      return 'success';
    } catch (e) {
      return 'fail';
    }
  }

  Future<String?> getUidFromUsername(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    } else {
      return querySnapshot.docs.first.id;
    }
  }

  Future<String> uploadProfileName(String name) async {
    final firestore = FirebaseFirestore.instance;
    final user = getUID();
    try {
      await firestore.collection('users').doc(user).update({'name': name});
      return 'success';
    } catch (e) {
      return 'fail';
    }
  }

  Future<String> uploadProfileUsername(String username) async {
    final firestore = FirebaseFirestore.instance;
    final user = getUID();
    try {
      await firestore
          .collection('users')
          .doc(user)
          .update({'username': username});
      return 'success';
    } catch (e) {
      return 'fail';
    }
  }

  Future<void> addUserDataToFirestore() async {
    final user = getUID();
    final firestore = FirebaseFirestore.instance;
    final userData = {
      'uid': user,
      'email': email,
      'username': username,
      'name': name,
      'fcmTokens': [],
      'blockedUsers': [],
      'isVerified': false,
      'profileData': {
        'likedPosts': [],
        'dislikedPosts': [],
        'pollVotes': {},
        'bio': '',
        'followers': [],
        'following': [],
        'likes': 0,
        'dislikes': 0,
        'profilePicture':
            'https://firebasestorage.googleapis.com/v0/b/untitled-2832f.appspot.com/o/profile_pictures%2Fdefault%2Fprofile.jpg?alt=media&token=2543c4eb-f991-468f-9ce8-68c576ffca7c',
      }
    };
    await firestore.collection('users').doc(user).set(userData);
    // await firestore
    //     .collection('users')
    //     .doc(user)
    //     .collection("arrays")
    //     .doc("likes")
    //     .set({"likes": []});
    await locator<CurrentUser>().addFCM();
  }

  Future<void> addFCM() async {
    if (!kIsWeb) {
      // TODO: eventually needs to support timestamp
      final user = getUID();
      final DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user);

      try {
        // Get the current data
        final DocumentSnapshot userSnapshot = await userDocRef.get();
        if (userSnapshot.exists) {
          final String currentDeviceToken =
              await FirebaseMessaging.instance.getToken() ?? '';
          // Retrieve the FCM tokens array
          // TODO: will change when in a collection
          if (userSnapshot.data().toString().contains('fcmTokens')) {
            List<String> fcmTokens =
                List<String>.from(userSnapshot['fcmTokens'] ?? []);

            // check to see if contained in array
            if (!fcmTokens.contains(currentDeviceToken)) {
              fcmTokens.add(currentDeviceToken);
            }
            // Update the Firestore document with the modified FCM tokens array
            await userDocRef.update({'fcmTokens': fcmTokens});
          } else {
            List<String> fcmTokens = [];
            fcmTokens.add(currentDeviceToken);
            userDocRef.update({'fcmTokens': fcmTokens});
          }
          setActivityNotification(true);
        }
      } catch (e) {
        // TODO: Handle the error as needed
      }
    }
  }

  Future<void> removeFCM() async {
    if (!kIsWeb) {
      // TODO: eventually needs to support timestamp
      final user = getUID();
      final DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user);

      try {
        // Get the current data
        final DocumentSnapshot userSnapshot = await userDocRef.get();
        if (userSnapshot.exists) {
          // Retrieve the FCM tokens array
          List<String> fcmTokens =
              List<String>.from(userSnapshot['fcmTokens'] ?? []);
          final String? currentDeviceToken =
              await FirebaseMessaging.instance.getToken();
          // Remove the current device's FCM token from the array
          fcmTokens.remove(currentDeviceToken);

          // Update the Firestore document with the modified FCM tokens array
          await userDocRef.update({'fcmTokens': fcmTokens});
          setActivityNotification(false);
        }
      } catch (e) {
        // TODO: Handle the error as needed
      }
    }
  }

  void clearVariables() {
    locator<PostsHandling>().feedChunks.clear();
    uid = '';

    name = '';
    likes = 0;
    dislikes = 0;
    pollVotes = {};
    bio = '';
    followers = [];
    following = [];
    username = '';

    email = '';
    likedPosts = [];
    dislikedPosts = [];
    profilePicture =
        'https://firebasestorage.googleapis.com/v0/b/untitled-2832f.appspot.com/o/profile_pictures%2Fdefault%2Fprofile.jpg?alt=media&token=2543c4eb-f991-468f-9ce8-68c576ffca7c';
  }

  signOut() async {
    await removeFCM();
    clearVariables();
    FirebaseAuth.instance.signOut();
  }

  Future<void> deleteAccount() async {
    await FirebaseAuth.instance.currentUser?.delete();
    clearVariables();
  }
}
