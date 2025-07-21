import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_to_ascii/image_to_ascii.dart';
import 'package:untitled_app/interfaces/post.dart';
import 'package:untitled_app/utilities/like_state.dart';
part '../generated/types/post.freezed.dart';
part '../generated/types/post.g.dart';

String _joinList(List<String>? list) {
  if (list == null) {
    return '';
  }
  return list.join('');
}

String? _asciiImageToString(AsciiImage? image) {
  if (image == null) return null;
  return image.toStorableString();
}

AsciiImage? _asciiImageFromString(String? image) {
  if (image == null) return null;
  return AsciiImage.fromStorableString(image);
}

@freezed
abstract class PostModel with _$PostModel {
  const PostModel._();
  const factory PostModel(
      {@JsonKey(name: 'author_uid', includeToJson: false) required String uid,
      required int id,
      @JsonKey(name: 'gif') String? gifUrl,
      @JsonKey(
          name: 'image',
          fromJson: _asciiImageFromString,
          toJson: _asciiImageToString)
      AsciiImage? image,
      @Default(<String>[])
      @JsonKey(fromJson: parseTextToTags, toJson: _joinList)
      List<String> title,
      @Default(<String>[])
      @JsonKey(fromJson: parseTextToTags, toJson: _joinList)
      List<String> body,
      @Default(0) @JsonKey(name: 'like_count', includeToJson: false) int likes,
      @Default(0)
      @JsonKey(name: 'dislike_count', includeToJson: false)
      int dislikes,
      @Default(0)
      @JsonKey(name: 'comment_count', includeToJson: false)
      int commentCount,
      @JsonKey(name: 'created_at', includeToJson: false)
      required String createdAt,
      List<String>? pollOptions,
      Map<String, int>? pollVoteCounts,
      @JsonKey(name: 'ekoed_id') int? ekoedId,
      @Default(false) @JsonKey(name: 'is_eko') bool isEko,
      @LikeStateConverter() @Default(LikeState.none) LikeState likeState,
      @JsonKey(name: 'chamber_id') int? chamberId}) = _PostModel;

  factory PostModel.fromJson(Map<String, dynamic> json) => _$PostModelFromJson({
        ...json,
        'likeState': {
          'is_liked': json['is_liked'],
          'is_disliked': json['is_disliked'],
        }
      });

  DateTime getDateTime() {
    return DateTime.tryParse(createdAt) ?? DateTime.now();
  }

  static Future<PostModel> fromFireStoreDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final json = doc.data();
    json['id'] = doc.id;
    json['commentCount'] = await countComments(doc.id);
    return PostModel.fromJson(json);
  }
}
