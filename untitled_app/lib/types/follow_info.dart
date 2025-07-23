import 'package:freezed_annotation/freezed_annotation.dart';

part '../generated/types/follow_info.freezed.dart';
part '../generated/types/follow_info.g.dart';

@freezed
abstract class FollowInfoModel with _$FollowInfoModel {
  const FollowInfoModel._();
  const factory FollowInfoModel({
    required int followers,
    required int following,
  }) = _FollowInfoModel;

  factory FollowInfoModel.fromJson(Map<String, dynamic> json) =>
      _$FollowInfoModelFromJson(json);
}
