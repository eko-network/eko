// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../types/follow_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FollowInfoModel _$FollowInfoModelFromJson(Map<String, dynamic> json) =>
    _FollowInfoModel(
      followers: (json['followers'] as num).toInt(),
      following: (json['following'] as num).toInt(),
    );

Map<String, dynamic> _$FollowInfoModelToJson(_FollowInfoModel instance) =>
    <String, dynamic>{
      'followers': instance.followers,
      'following': instance.following,
    };
