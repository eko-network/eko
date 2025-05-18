import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:untitled_app/types/user.dart';

part '../generated/types/current_user.freezed.dart';

@freezed
abstract class CurrentUserModel with _$CurrentUserModel {
  const factory CurrentUserModel({
    required UserModel user,
    required Set<String> likedPosts,
    required Set<String> dislikedPosts,
    required Set<String> blockedUsers,
    required Set<String> blockedBy,
    required Map<String, int> pollVotes,
  }) = _CurrentUserModel;
  factory CurrentUserModel.fromJson(Map<String, dynamic> json) {
    return CurrentUserModel(
      user: UserModel.fromJson(json),
      likedPosts: Set<String>.from(json['profileData']['likedPosts'] ?? []),
      dislikedPosts:
          Set<String>.from(json['profileData']['dislikedPosts'] ?? []),
      pollVotes: Map<String, int>.from(json['profileData']['pollVotes'] ?? {}),
      blockedBy: Set<String>.from(json['blockedBy'] ?? []),
      blockedUsers: Set<String>.from(json['blockedUsers'] ?? []),
    );
  }
  // this is the initial state of the current user. It is only to make the current user not nullable
  factory CurrentUserModel.loading() {
    return CurrentUserModel(
      user: UserModel.userNotFound(),
      dislikedPosts: {},
      likedPosts: {},
      blockedUsers: {},
      blockedBy: {},
      pollVotes: {},
    );
  }
}
