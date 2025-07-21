import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:untitled_app/interfaces/post.dart';
import 'package:untitled_app/utilities/like_state.dart';
part '../generated/types/comment.freezed.dart';
part '../generated/types/comment.g.dart';

String _joinList(List<String>? list) {
  if (list == null) {
    return '';
  }
  return list.join('');
}

@freezed
abstract class CommentModel with _$CommentModel {
  const CommentModel._();
  const factory CommentModel({
    @JsonKey(name: 'author_uid') required String uid,
    required int id,
    @JsonKey(name: 'parent_post_id') required int parentId,
    @JsonKey(name: 'gif') String? gifUrl,
    @Default(<String>[])
    @JsonKey(
      fromJson: parseTextToTags,
      toJson: _joinList,
    )
    List<String> body,
    @Default(0) @JsonKey(name: 'like_count') int likes,
    @Default(0) @JsonKey(name: 'dislike_count') int dislikes,
    @JsonKey(name: 'created_at') required String createdAt,
    @LikeStateConverter() @Default(LikeState.none) LikeState likeState,
  }) = _CommentModel;

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson({
        ...json,
        'likeState': {
          'is_liked': json['is_liked'],
          'is_disliked': json['is_disliked'],
        }
      });

  DateTime getDateTime() {
    return DateTime.tryParse(createdAt) ?? DateTime.now();
  }

  static Future<CommentModel> fromFireStoreDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final json = doc.data();
    json['id'] = doc.id;
    json['postId'] = doc.reference.parent.parent?.id;
    return CommentModel.fromJson(json);
  }
}
