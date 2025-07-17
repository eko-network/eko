import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part '../generated/types/group.freezed.dart';
part '../generated/types/group.g.dart';

@freezed
abstract class GroupModel with _$GroupModel {
  @JsonSerializable(explicitToJson: true)
  const factory GroupModel({
    required int id,
    required String name,
    String? description,
    @JsonKey(name: 'latest_post_time') String? lastActivity,
    String? icon,
  }) = _GroupModel;

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);
}
