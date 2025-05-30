// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../types/activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ActivityModel _$ActivityModelFromJson(Map<String, dynamic> json) =>
    _ActivityModel(
      sourceUid: json['sourceUid'] as String? ?? null,
      id: json['id'] as String,
      createdAt: json['time'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
      type: json['type'] as String? ?? '',
      content: json['content'] as String? ?? '',
      path: json['path'] as String? ?? '',
    );

Map<String, dynamic> _$ActivityModelToJson(_ActivityModel instance) =>
    <String, dynamic>{
      'sourceUid': instance.sourceUid,
      'id': instance.id,
      'time': instance.createdAt,
      'tags': instance.tags,
      'type': instance.type,
      'content': instance.content,
      'path': instance.path,
    };
