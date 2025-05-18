// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../types/comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommentModel _$CommentModelFromJson(Map<String, dynamic> json) =>
    _CommentModel(
      uid: json['uid'] as String,
      id: json['id'] as String,
      postId: json['postId'] as String,
      gifUrl: json['gifUrl'] as String?,
      body: (json['body'] as List<dynamic>?)?.map((e) => e as String).toList(),
      likes: (json['likes'] as num).toInt(),
      dislikes: (json['dislikes'] as num).toInt(),
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$CommentModelToJson(_CommentModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'id': instance.id,
      'postId': instance.postId,
      'gifUrl': instance.gifUrl,
      'body': instance.body,
      'likes': instance.likes,
      'dislikes': instance.dislikes,
      'createdAt': instance.createdAt,
    };
