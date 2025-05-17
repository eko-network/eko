// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../types/group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupModel _$GroupModelFromJson(Map<String, dynamic> json) => _GroupModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String,
      lastActivity: json['lastActivity'] as String,
      createdOn: json['createdOn'] as String,
      icon: json['icon'] as String,
      members:
          (json['members'] as List<dynamic>).map((e) => e as String).toList(),
      notSeen:
          (json['notSeen'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$GroupModelToJson(_GroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'lastActivity': instance.lastActivity,
      'createdOn': instance.createdOn,
      'icon': instance.icon,
      'members': instance.members,
      'notSeen': instance.notSeen,
    };
