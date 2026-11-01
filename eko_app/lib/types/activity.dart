import 'package:freezed_annotation/freezed_annotation.dart';

part '../generated/types/activity.freezed.dart';
part '../generated/types/activity.g.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum ActivityType { postTag, commentTag, follow, comment, eko }

@freezed
abstract class ActivityModel with _$ActivityModel {
  const ActivityModel._();

  const factory ActivityModel({
    @JsonKey(name: 'source_uid') required String sourceUid,
    required int id,
    @JsonKey(name: 'post_id') int? postId,
    @JsonKey(name: 'comment_id') int? commentId,
    @JsonKey(name: 'created_at') required String createdAt,
    required ActivityType type,
  }) = _ActivityModel;

  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);

  DateTime get dateTime => DateTime.tryParse(createdAt) ?? DateTime.now();
}
