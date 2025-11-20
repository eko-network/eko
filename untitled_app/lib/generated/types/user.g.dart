// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../types/user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
      name: json['name'] as String,
      username: json['username'] as String,
      profilePicture: json['profilePicture'] as String,
      bio: json['bio'] as String,
      followers:
          (json['followers'] as List<dynamic>).map((e) => e as String).toList(),
      following:
          (json['following'] as List<dynamic>).map((e) => e as String).toList(),
      uid: json['uid'] as String,
      isVerified: json['isVerified'] as bool,
      verificationUrl: json['verificationUrl'] as String?,
      shareOnlineStatus: json['share_online_status'] as bool,
    );

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'username': instance.username,
      'profilePicture': instance.profilePicture,
      'bio': instance.bio,
      'followers': instance.followers,
      'following': instance.following,
      'uid': instance.uid,
      'isVerified': instance.isVerified,
      'verificationUrl': instance.verificationUrl,
      'share_online_status': instance.shareOnlineStatus,
    };
