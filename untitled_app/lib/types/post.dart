import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_to_ascii/image_to_ascii.dart';
import 'package:untitled_app/interfaces/post.dart';
import 'dart:convert';
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
  const factory PostModel({
    @JsonKey(name: 'author') required String uid,
    required String id,
    String? gifUrl,
    @JsonKey(
        name: 'image',
        fromJson: _asciiImageFromString,
        toJson: _asciiImageToString)
    AsciiImage? imageString,
    @Default(<String>[])
    @JsonKey(
      fromJson: parseTextToTags,
      toJson: _joinList,
    )
    List<String> title,
    @Default(<String>[])
    @JsonKey(
      fromJson: parseTextToTags,
      toJson: _joinList,
    )
    List<String> body,
    @Default(['public']) List<String> tags,
    @Default(0) int likes,
    @Default(0) int dislikes,
    @Default(0) int commentCount,
    @JsonKey(name: 'time') required String createdAt,
    List<String>? pollOptions,
    Map<String, int>? pollVoteCounts,
  }) = _PostModel;

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

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
