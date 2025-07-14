// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../types/post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostModel _$PostModelFromJson(Map<String, dynamic> json) => _PostModel(
      uid: json['author_uid'] as String,
      id: (json['id'] as num).toInt(),
      gifUrl: json['gif'] as String?,
      image: _asciiImageFromString(json['image'] as String?),
      title: json['title'] == null
          ? const <String>[]
          : parseTextToTags(json['title'] as String?),
      body: json['body'] == null
          ? const <String>[]
          : parseTextToTags(json['body'] as String?),
      likes: (json['like_count'] as num?)?.toInt() ?? 0,
      dislikes: (json['dislike_count'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String,
      pollOptions: (json['pollOptions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      pollVoteCounts: (json['pollVoteCounts'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      ekoedId: (json['ekoed_id'] as num?)?.toInt(),
      isEko: json['is_eko'] as bool? ?? false,
      chamberId: json['chamber_id'] as String?,
    );

Map<String, dynamic> _$PostModelToJson(_PostModel instance) =>
    <String, dynamic>{
      'author_uid': instance.uid,
      'id': instance.id,
      'gif': instance.gifUrl,
      'image': _asciiImageToString(instance.image),
      'title': _joinList(instance.title),
      'body': _joinList(instance.body),
      'like_count': instance.likes,
      'dislike_count': instance.dislikes,
      'comment_count': instance.commentCount,
      'created_at': instance.createdAt,
      'pollOptions': instance.pollOptions,
      'pollVoteCounts': instance.pollVoteCounts,
      'ekoed_id': instance.ekoedId,
      'is_eko': instance.isEko,
      'chamber_id': instance.chamberId,
    };
