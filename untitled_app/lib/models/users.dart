import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled_app/models/current_user.dart';

class AppUser {
  String name;
  String username;
  String profilePicture;
  String bio;
  int likes;
  int dislikes;
  List<dynamic> followers;
  List<dynamic> following;
  String uid;
  int? pageIndex; //for search pagination
  bool isVerified;

  AppUser({
    this.pageIndex,
    this.uid = '',
    this.name = '',
    this.likes = 0,
    this.dislikes = 0,
    this.bio = '',
    this.followers = const [],
    this.following = const [],
    this.username = '',
    this.isVerified = false,
    this.profilePicture =
        "https://firebasestorage.googleapis.com/v0/b/untitled-2832f.appspot.com/o/profile_pictures%2Fdefault%2Fprofile.jpg?alt=media&token=2543c4eb-f991-468f-9ce8-68c576ffca7c",
  }) {
    if (followers.isEmpty) {
      followers = [];
    }
    if (following.isEmpty) {
      following = [];
    }
  }
  static AppUser fromCurrent(CurrentUser user) {
    return AppUser(
      username: user.username,
      uid: user.uid,
      name: user.name,
      profilePicture: user.profilePicture,
      likes: user.hashCode,
      bio: user.bio,
      followers: user.followers,
      following: user.following,
      isVerified: user.isVerified,
    );
  }

  static AppUser fromJson(Map<String, dynamic> json, {int? page}) {
    return AppUser(
        pageIndex: page,
        username: json['username'],
        uid: json['uid'],
        name: json['name'],
        profilePicture: json['profileData']['profilePicture'],
        likes: json['profileData']["likes"],
        dislikes: json['profileData']["dislikes"],
        bio: json['profileData']['bio'],
        followers: json['profileData']['followers'],
        following: json['profileData']['following'],
        isVerified: json['isVerified'] ?? false);
  }

  Future<Map<String, dynamic>?> readUserData(String? passedUid,
      {AppUser? user}) async {
    uid = passedUid ?? uid;
    //checks if post author is the current user because then data can be saved by not getting there info. Must have toggle so that profile doesn't try to save data.
    if (user != null) {
      if (passedUid == user.uid) {
        profilePicture = user.profilePicture;
        followers = user.followers;
        following = user.following;
        likes = user.likes;
        dislikes = user.dislikes;
        username = user.username;
        name = user.name;
        bio = user.bio;
        isVerified = user.isVerified;
        return null;
      }
    }

    final userRef = FirebaseFirestore.instance.collection("users");
    final data =
        await userRef.doc(uid).get(); //FIXME need exception handleing all below

    final userData = data.data();
    if (userData != null) {
      profilePicture = userData['profileData']['profilePicture'];
      followers = userData['profileData']['followers'];
      following = userData['profileData']['following'];
      likes = userData['profileData']['likes'];
      dislikes = userData['profileData']['dislikes'] ?? 0;
      username = userData['username'];
      name = userData['name'];
      isVerified = userData['isVerified'] ?? false;

      bio = userData['profileData']['bio'] ?? '';
    }
    //print(username);
    return userData;
  }

  // Future<List<AppUser>> userListGetter(List<dynamic> users){

  // }
}
