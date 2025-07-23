// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../types/follow_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FollowInfoModel {
  int get followers;
  int get following;

  /// Create a copy of FollowInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FollowInfoModelCopyWith<FollowInfoModel> get copyWith =>
      _$FollowInfoModelCopyWithImpl<FollowInfoModel>(
          this as FollowInfoModel, _$identity);

  /// Serializes this FollowInfoModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FollowInfoModel &&
            (identical(other.followers, followers) ||
                other.followers == followers) &&
            (identical(other.following, following) ||
                other.following == following));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, followers, following);

  @override
  String toString() {
    return 'FollowInfoModel(followers: $followers, following: $following)';
  }
}

/// @nodoc
abstract mixin class $FollowInfoModelCopyWith<$Res> {
  factory $FollowInfoModelCopyWith(
          FollowInfoModel value, $Res Function(FollowInfoModel) _then) =
      _$FollowInfoModelCopyWithImpl;
  @useResult
  $Res call({int followers, int following});
}

/// @nodoc
class _$FollowInfoModelCopyWithImpl<$Res>
    implements $FollowInfoModelCopyWith<$Res> {
  _$FollowInfoModelCopyWithImpl(this._self, this._then);

  final FollowInfoModel _self;
  final $Res Function(FollowInfoModel) _then;

  /// Create a copy of FollowInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? followers = null,
    Object? following = null,
  }) {
    return _then(_self.copyWith(
      followers: null == followers
          ? _self.followers
          : followers // ignore: cast_nullable_to_non_nullable
              as int,
      following: null == following
          ? _self.following
          : following // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _FollowInfoModel extends FollowInfoModel {
  const _FollowInfoModel({required this.followers, required this.following})
      : super._();
  factory _FollowInfoModel.fromJson(Map<String, dynamic> json) =>
      _$FollowInfoModelFromJson(json);

  @override
  final int followers;
  @override
  final int following;

  /// Create a copy of FollowInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FollowInfoModelCopyWith<_FollowInfoModel> get copyWith =>
      __$FollowInfoModelCopyWithImpl<_FollowInfoModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$FollowInfoModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FollowInfoModel &&
            (identical(other.followers, followers) ||
                other.followers == followers) &&
            (identical(other.following, following) ||
                other.following == following));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, followers, following);

  @override
  String toString() {
    return 'FollowInfoModel(followers: $followers, following: $following)';
  }
}

/// @nodoc
abstract mixin class _$FollowInfoModelCopyWith<$Res>
    implements $FollowInfoModelCopyWith<$Res> {
  factory _$FollowInfoModelCopyWith(
          _FollowInfoModel value, $Res Function(_FollowInfoModel) _then) =
      __$FollowInfoModelCopyWithImpl;
  @override
  @useResult
  $Res call({int followers, int following});
}

/// @nodoc
class __$FollowInfoModelCopyWithImpl<$Res>
    implements _$FollowInfoModelCopyWith<$Res> {
  __$FollowInfoModelCopyWithImpl(this._self, this._then);

  final _FollowInfoModel _self;
  final $Res Function(_FollowInfoModel) _then;

  /// Create a copy of FollowInfoModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? followers = null,
    Object? following = null,
  }) {
    return _then(_FollowInfoModel(
      followers: null == followers
          ? _self.followers
          : followers // ignore: cast_nullable_to_non_nullable
              as int,
      following: null == following
          ? _self.following
          : following // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
