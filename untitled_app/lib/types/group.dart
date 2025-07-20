import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part '../generated/types/group.freezed.dart';
part '../generated/types/group.g.dart';

@freezed
abstract class GroupModel with _$GroupModel {
  @JsonSerializable(explicitToJson: true)
  // ignore: unused_element
  const GroupModel._();

  const factory GroupModel({
    required int id,
    required String name,
    String? description,
    @JsonKey(name: 'latest_post_time') required String lastActivity,
    String? icon,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _GroupModel;

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);
  String getIcon() {
    return icon ?? name[0];
  }
}
