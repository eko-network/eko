// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../types/post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostModel _$PostModelFromJson(Map<String, dynamic> json) => _PostModel(
  uid: json['author_uid'] as String,
  id: (json['id'] as num).toInt(),
  gifUrl: json['gif'] as String?,
  imageString: _asciiImageFromString(json['image'] as String?),
  title: json['title'] as String?,
  body: json['body'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const ['public'],
  likes: (json['like_count'] as num?)?.toInt() ?? 0,
  dislikes: (json['dislike_count'] as num?)?.toInt() ?? 0,
  commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
  isLiked: json['is_liked'] as bool? ?? false,
  isDisliked: json['is_disliked'] as bool? ?? false,
  createdAt: json['created_at'] as String,
  poll: (json['poll'] as List<dynamic>?)
      ?.map((e) => PollOptionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  vote: (json['vote'] as num?)?.toInt(),
  repostId: (json['ekoed_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$PostModelToJson(_PostModel instance) =>
    <String, dynamic>{
      'author_uid': instance.uid,
      'id': instance.id,
      'gif': instance.gifUrl,
      'image': _asciiImageToString(instance.imageString),
      'title': instance.title,
      'body': instance.body,
      'tags': instance.tags,
      'like_count': instance.likes,
      'dislike_count': instance.dislikes,
      'comment_count': instance.commentCount,
      'is_liked': instance.isLiked,
      'is_disliked': instance.isDisliked,
      'created_at': instance.createdAt,
      'poll': instance.poll,
      'vote': instance.vote,
      'ekoed_id': instance.repostId,
    };

_PollOptionModel _$PollOptionModelFromJson(Map<String, dynamic> json) =>
    _PollOptionModel(
      value: json['value'] as String,
      optionId: (json['option_id'] as num).toInt(),
      voteCount: (json['vote_count'] as num).toInt(),
    );

Map<String, dynamic> _$PollOptionModelToJson(_PollOptionModel instance) =>
    <String, dynamic>{
      'value': instance.value,
      'option_id': instance.optionId,
      'vote_count': instance.voteCount,
    };
