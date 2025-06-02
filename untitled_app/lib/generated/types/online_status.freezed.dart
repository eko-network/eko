// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../types/online_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
OnlineStatus _$OnlineStatusFromJson(Map<String, dynamic> json) {
  return _.fromJson(json);
}

/// @nodoc
mixin _$OnlineStatus implements DiagnosticableTreeMixin {
  bool get online;
  @JsonKey(name: 'last_changed')
  int get lastChanged;

  /// Create a copy of OnlineStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OnlineStatusCopyWith<OnlineStatus> get copyWith =>
      _$OnlineStatusCopyWithImpl<OnlineStatus>(
          this as OnlineStatus, _$identity);

  /// Serializes this OnlineStatus to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'OnlineStatus'))
      ..add(DiagnosticsProperty('online', online))
      ..add(DiagnosticsProperty('lastChanged', lastChanged));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OnlineStatus &&
            (identical(other.online, online) || other.online == online) &&
            (identical(other.lastChanged, lastChanged) ||
                other.lastChanged == lastChanged));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, online, lastChanged);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'OnlineStatus(online: $online, lastChanged: $lastChanged)';
  }
}

/// @nodoc
abstract mixin class $OnlineStatusCopyWith<$Res> {
  factory $OnlineStatusCopyWith(
          OnlineStatus value, $Res Function(OnlineStatus) _then) =
      _$OnlineStatusCopyWithImpl;
  @useResult
  $Res call({bool online, @JsonKey(name: 'last_changed') int lastChanged});
}

/// @nodoc
class _$OnlineStatusCopyWithImpl<$Res> implements $OnlineStatusCopyWith<$Res> {
  _$OnlineStatusCopyWithImpl(this._self, this._then);

  final OnlineStatus _self;
  final $Res Function(OnlineStatus) _then;

  /// Create a copy of OnlineStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? online = null,
    Object? lastChanged = null,
  }) {
    return _then(_self.copyWith(
      online: null == online
          ? _self.online
          : online // ignore: cast_nullable_to_non_nullable
              as bool,
      lastChanged: null == lastChanged
          ? _self.lastChanged
          : lastChanged // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ with DiagnosticableTreeMixin implements OnlineStatus {
  const _(
      {required this.online,
      @JsonKey(name: 'last_changed') required this.lastChanged});
  factory _.fromJson(Map<String, dynamic> json) => _$FromJson(json);

  @override
  final bool online;
  @override
  @JsonKey(name: 'last_changed')
  final int lastChanged;

  /// Create a copy of OnlineStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CopyWith<_> get copyWith => __$CopyWithImpl<_>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'OnlineStatus'))
      ..add(DiagnosticsProperty('online', online))
      ..add(DiagnosticsProperty('lastChanged', lastChanged));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ &&
            (identical(other.online, online) || other.online == online) &&
            (identical(other.lastChanged, lastChanged) ||
                other.lastChanged == lastChanged));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, online, lastChanged);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'OnlineStatus(online: $online, lastChanged: $lastChanged)';
  }
}

/// @nodoc
abstract mixin class _$CopyWith<$Res> implements $OnlineStatusCopyWith<$Res> {
  factory _$CopyWith(_ value, $Res Function(_) _then) = __$CopyWithImpl;
  @override
  @useResult
  $Res call({bool online, @JsonKey(name: 'last_changed') int lastChanged});
}

/// @nodoc
class __$CopyWithImpl<$Res> implements _$CopyWith<$Res> {
  __$CopyWithImpl(this._self, this._then);

  final _ _self;
  final $Res Function(_) _then;

  /// Create a copy of OnlineStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? online = null,
    Object? lastChanged = null,
  }) {
    return _then(_(
      online: null == online
          ? _self.online
          : online // ignore: cast_nullable_to_non_nullable
              as bool,
      lastChanged: null == lastChanged
          ? _self.lastChanged
          : lastChanged // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
