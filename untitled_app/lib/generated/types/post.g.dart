// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../types/post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostModel _$PostModelFromJson(Map<String, dynamic> json) => _PostModel(
      uid: json['uid'] as String,
      id: json['id'] as String,
      gifUrl: json['gifUrl'] as String?,
      imageString: json['imageString'] as String?,
      title:
          (json['title'] as List<dynamic>?)?.map((e) => e as String).toList(),
      body: (json['body'] as List<dynamic>?)?.map((e) => e as String).toList(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      likes: (json['likes'] as num).toInt(),
      dislikes: (json['dislikes'] as num).toInt(),
      commentCount: (json['commentCount'] as num).toInt(),
      createdAt: json['createdAt'] as String,
      isPoll: json['isPoll'] as bool,
      pollOptions: (json['pollOptions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      pollVoteCounts: (json['pollVoteCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
    );

Map<String, dynamic> _$PostModelToJson(_PostModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'id': instance.id,
      'gifUrl': instance.gifUrl,
      'imageString': instance.imageString,
      'title': instance.title,
      'body': instance.body,
      'tags': instance.tags,
      'likes': instance.likes,
      'dislikes': instance.dislikes,
      'commentCount': instance.commentCount,
      'createdAt': instance.createdAt,
      'isPoll': instance.isPoll,
      'pollOptions': instance.pollOptions,
      'pollVoteCounts': instance.pollVoteCounts,
    };
