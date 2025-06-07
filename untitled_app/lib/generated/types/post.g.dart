// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../types/post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostModel _$PostModelFromJson(Map<String, dynamic> json) => _PostModel(
      uid: json['author'] as String,
      id: json['id'] as String,
      gifUrl: json['gifUrl'] as String?,
      imageString: _asciiImageFromString(json['image'] as String?),
      title: json['title'] == null
          ? const <String>[]
          : parseTextToTags(json['title'] as String?),
      body: json['body'] == null
          ? const <String>[]
          : parseTextToTags(json['body'] as String?),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const ['public'],
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      dislikes: (json['dislikes'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      createdAt: json['time'] as String,
      pollOptions: (json['pollOptions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      pollVoteCounts: (json['pollVoteCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
    );

Map<String, dynamic> _$PostModelToJson(_PostModel instance) =>
    <String, dynamic>{
      'author': instance.uid,
      'id': instance.id,
      'gifUrl': instance.gifUrl,
      'image': _asciiImageToString(instance.imageString),
      'title': _joinList(instance.title),
      'body': _joinList(instance.body),
      'tags': instance.tags,
      'likes': instance.likes,
      'dislikes': instance.dislikes,
      'commentCount': instance.commentCount,
      'time': instance.createdAt,
      'pollOptions': instance.pollOptions,
      'pollVoteCounts': instance.pollVoteCounts,
    };
