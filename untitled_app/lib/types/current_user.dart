import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:untitled_app/types/user.dart';
part '../generated/types/current_user.freezed.dart';

@freezed
abstract class CurrentUserModel with _$CurrentUserModel {
  const factory CurrentUserModel({
    required UserModel user,
    required List<String> likedPosts,
    required List<String> dislikedPosts,
    required List<String> blockedUsers,
    required List<String> blockedBy,
    required Map<String, int> pollVotes,
  }) = _CurrentUserModel;
  factory CurrentUserModel.fromJson(Map<String, dynamic> json) {
    return CurrentUserModel(
      user: UserModel.fromJson(json),
      likedPosts: List<String>.from(json['profileData']['likedPosts'] ?? []),
      dislikedPosts:
          List<String>.from(json['profileData']['dislikedPosts'] ?? []),
      pollVotes: Map<String, int>.from(json['profileData']['pollVotes'] ?? {}),
      blockedBy: List<String>.from(json['blockedBy'] ?? []),
      blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
    );
  }
}
