import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part '../generated/types/online_status.freezed.dart';
part '../generated/types/online_status.g.dart';

@freezed
abstract class OnlineStatus with _$OnlineStatus {
  @JsonSerializable(explicitToJson: true)
  const factory OnlineStatus({
    required bool online,
    @JsonKey(name: 'last_changed') required int lastChanged,
  }) = _;

  factory OnlineStatus.fromJson(Map<String, dynamic> json) =>
      _$OnlineStatusFromJson(json);
}
