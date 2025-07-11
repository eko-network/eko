// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../types/user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
      name: json['name'] as String,
      username: json['username'] as String,
      profilePicture: json['profile_picture'] as String? ??
          'https://firebasestorage.googleapis.com/v0/b/untitled-2832f.appspot.com/o/profile_pictures%2Fdefault%2Fprofile.jpg?alt=media&token=2543c4eb-f991-468f-9ce8-68c576ffca7c',
      bio: json['bio'] as String? ?? '',
      uid: json['id'] as String,
      isVerified: json['is_verified'] as bool? ?? false,
      shareOnlineStatus: json['share_online_status'] as bool? ?? true,
    );

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'username': instance.username,
      'profile_picture': instance.profilePicture,
      'bio': instance.bio,
      'id': instance.uid,
      'is_verified': instance.isVerified,
      'share_online_status': instance.shareOnlineStatus,
    };
