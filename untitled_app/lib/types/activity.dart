import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part '../generated/types/activity.freezed.dart';
part '../generated/types/activity.g.dart';

@freezed
abstract class ActivityModel with _$ActivityModel {
  const ActivityModel._();
  const factory ActivityModel({
    @Default(null) String? sourceUid,
    required String id,
    @JsonKey(name: 'time') required String createdAt,
    @Default(<String>[]) List<String> tags,
    @Default('') String type,
    @Default('') String content,
    @Default('') String path,
  }) = _ActivityModel;

  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);

  DateTime getDateTime() {
    return DateTime.tryParse(createdAt) ?? DateTime.now();
  }

  static ActivityModel fromFirestoreDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final json = doc.data()!;
    json['id'] = doc.id;
    return ActivityModel.fromJson(json);
  }
}
