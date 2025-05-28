// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../types/gif_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TenorResponse _$TenorResponseFromJson(Map<String, dynamic> json) =>
    _TenorResponse(
      results: (json['results'] as List<dynamic>)
          .map((e) => TenorResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TenorResponseToJson(_TenorResponse instance) =>
    <String, dynamic>{
      'results': instance.results.map((e) => e.toJson()).toList(),
    };

_TenorResult _$TenorResultFromJson(Map<String, dynamic> json) => _TenorResult(
      id: json['id'] as String,
      title: json['title'] as String,
      mediaFormats:
          MediaFormats.fromJson(json['media_formats'] as Map<String, dynamic>),
      contentDescription: json['content_description'] as String?,
      itemurl: json['itemurl'] as String,
      url: json['url'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$TenorResultToJson(_TenorResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'media_formats': instance.mediaFormats.toJson(),
      'content_description': instance.contentDescription,
      'itemurl': instance.itemurl,
      'url': instance.url,
      'tags': instance.tags,
    };

_MediaFormats _$MediaFormatsFromJson(Map<String, dynamic> json) =>
    _MediaFormats(
      gif: GifFormat.fromJson(json['gif'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MediaFormatsToJson(_MediaFormats instance) =>
    <String, dynamic>{
      'gif': instance.gif.toJson(),
    };

_GifFormat _$GifFormatFromJson(Map<String, dynamic> json) => _GifFormat(
      url: json['url'] as String,
      duration: (json['duration'] as num).toDouble(),
      preview: json['preview'] as String,
      dims: (json['dims'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      size: (json['size'] as num).toInt(),
    );

Map<String, dynamic> _$GifFormatToJson(_GifFormat instance) =>
    <String, dynamic>{
      'url': instance.url,
      'duration': instance.duration,
      'preview': instance.preview,
      'dims': instance.dims,
      'size': instance.size,
    };
