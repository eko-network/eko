// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../types/online_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ _$FromJson(Map<String, dynamic> json) => _(
      online: json['online'] as bool? ?? false,
      id: json['id'] as String?,
      lastChanged: (json['last_changed'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ToJson(_ instance) => <String, dynamic>{
      'online': instance.online,
      'id': instance.id,
      'last_changed': instance.lastChanged,
    };
