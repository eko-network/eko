import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part '../generated/types/group.freezed.dart';
part '../generated/types/group.g.dart';

@freezed
abstract class GroupModel with _$GroupModel {
  @JsonSerializable(explicitToJson: true)
  const factory GroupModel({
    @Default('') String id,
    required String name,
    required String description,
    required String lastActivity,
    required String createdOn,
    required String icon,
    required List<String> members,
    required List<String> notSeen,
  }) = _GroupModel;

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);

  static GroupModel fromFirestore(Map<String, dynamic> json, String id) =>
      GroupModel.fromJson(json).copyWith(id: id);
}
