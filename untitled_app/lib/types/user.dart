import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:untitled_app/types/current_user.dart';
part '../generated/types/user.freezed.dart';
part '../generated/types/user.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  @JsonSerializable(explicitToJson: true)
  const factory UserModel({
    @Default('') String name,
    required String username,
    @JsonKey(
        name: 'profile_picture',
        defaultValue:
            'https://firebasestorage.googleapis.com/v0/b/untitled-2832f.appspot.com/o/profile_pictures%2Fdefault%2Fprofile.jpg?alt=media&token=2543c4eb-f991-468f-9ce8-68c576ffca7c')
    required String profilePicture,
    @JsonKey(defaultValue: '') required String bio,
    @JsonKey(name: 'id') required String uid,
    @JsonKey(name: 'is_verified', defaultValue: false) required bool isVerified,
    @JsonKey(name: 'share_online_status', defaultValue: true)
    required bool shareOnlineStatus,
  }) = _UserModel;

  factory UserModel.userNotFound() {
    return UserModel(
      isVerified: false,
      username: '',
      name: '',
      profilePicture:
          'https://firebasestorage.googleapis.com/v0/b/untitled-2832f.appspot.com/o/profile_pictures%2Fdefault%2Fprofile.jpg?alt=media&token=2543c4eb-f991-468f-9ce8-68c576ffca7c',
      bio: '',
      uid: '',
      shareOnlineStatus: false,
    );
  }

//   factory UserModel.fromJson(Map<String, dynamic>? json) {
//     if (json == null) return UserModel.userNotFound();
//     final profileData = json['profileData'] ?? {};
//     return UserModel(
//       name: json['name'] ?? '',
//       username: json['username'] ?? '',
//       profilePicture: profileData['profilePicture'] ??
//           'https://firebasestorage.googleapis.com/v0/b/untitled-2832f.appspot.com/o/profile_pictures%2Fdefault%2Fprofile.jpg?alt=media&token=2543c4eb-f991-468f-9ce8-68c576ffca7c',
//       bio: profileData['bio'] ?? '',
//       uid: json['uid'] ?? '',
//       isVerified: json['is_verified'] ?? false,
//       shareOnlineStatus: json['share_online_status'] ?? true,
//     );
//   }
// }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
