import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part '../generated/types/online_status.freezed.dart';
part '../generated/types/online_status.g.dart';

@freezed
abstract class OnlineStatus with _$OnlineStatus {
  @JsonSerializable(explicitToJson: true)
  const factory OnlineStatus({
    // if there is a deveice online
    @Default(false) bool online,
    // true if current device id matches the active device
    @JsonKey(includeFromJson: false) @Default(true) bool valid,
    // the id of the active device
    String? id,
    // timestamp of last change
    @JsonKey(name: 'last_changed') int? lastChanged,
  }) = _;
  factory OnlineStatus.fromJson(Map<String, dynamic> json) =>
      _$OnlineStatusFromJson(json);
}
