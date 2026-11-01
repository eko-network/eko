import 'package:freezed_annotation/freezed_annotation.dart';
part '../generated/types/user.freezed.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String name,
    required String username,
    required String profilePicture,
    required String bio,
    required String uid,
    required bool isVerified,
    String? verificationUrl,
    required bool shareOnlineStatus,
    @Default(false) bool isFollowing,
  }) = _UserModel;

  factory UserModel.userNotFound() {
    return UserModel(
      isVerified: false,
      username: '',
      name: '',
      profilePicture: '',
      bio: '',
      uid: '',
      shareOnlineStatus: false,
      isFollowing: false,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserModel.userNotFound();
    List<String> asStrList(Object? value) {
      if (value is List) {
        return value.map((e) => '$e').toList();
      }
      return const <String>[];
    }

    final profileDataRaw = json['profileData'] ?? json['profile_data'];
    final profileData = profileDataRaw is Map
        ? Map<String, dynamic>.from(profileDataRaw)
        : <String, dynamic>{};

    final profilePicture =
        profileData['profilePicture'] ??
        profileData['profile_picture'] ??
        json['profile_picture'] ??
        '';
    final bio = profileData['bio'] ?? json['bio'] ?? '';

    return UserModel(
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      profilePicture: '$profilePicture',
      bio: '$bio',
      uid: '${json['uid'] ?? json['id'] ?? ''}',
      isVerified: json['isVerified'] ?? json['is_verified'] ?? false,
      shareOnlineStatus:
          json['shareOnlineStatus'] ?? json['share_online_status'] ?? true,
      verificationUrl: json['verificationUrl'] ?? json['verification_url'],
      isFollowing: json['isFollowing'] ?? json['is_following'] ?? false,
    );
  }
}
