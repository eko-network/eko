// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../types/comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommentModel _$CommentModelFromJson(Map<String, dynamic> json) =>
    _CommentModel(
      uid: json['author_uid'] as String,
      id: (json['id'] as num).toInt(),
      parentId: (json['parent_post_id'] as num).toInt(),
      gifUrl: json['gif'] as String?,
      body: json['body'] == null
          ? const <String>[]
          : parseTextToTags(json['body'] as String?),
      likes: (json['like_count'] as num?)?.toInt() ?? 0,
      dislikes: (json['dislike_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String,
      likeState: json['likeState'] == null
          ? LikeState.none
          : const LikeStateConverter()
              .fromJson(json['likeState'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CommentModelToJson(_CommentModel instance) =>
    <String, dynamic>{
      'author_uid': instance.uid,
      'id': instance.id,
      'parent_post_id': instance.parentId,
      'gif': instance.gifUrl,
      'body': _joinList(instance.body),
      'like_count': instance.likes,
      'dislike_count': instance.dislikes,
      'created_at': instance.createdAt,
      'likeState': const LikeStateConverter().toJson(instance.likeState),
    };
