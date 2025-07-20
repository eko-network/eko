// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../types/group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupModel _$GroupModelFromJson(Map<String, dynamic> json) => _GroupModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      lastActivity: json['latest_post_time'] as String?,
      icon: json['icon'] as String?,
      createdAt: json['created_at'],
    );

Map<String, dynamic> _$GroupModelToJson(_GroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'latest_post_time': instance.lastActivity,
      'icon': instance.icon,
      'created_at': instance.createdAt,
    };
