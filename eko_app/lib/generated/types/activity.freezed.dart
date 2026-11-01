// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../types/activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ActivityModel {

@JsonKey(name: 'source_uid') String get sourceUid; int get id;@JsonKey(name: 'post_id') int? get postId;@JsonKey(name: 'comment_id') int? get commentId;@JsonKey(name: 'created_at') String get createdAt; ActivityType get type;
/// Create a copy of ActivityModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityModelCopyWith<ActivityModel> get copyWith => _$ActivityModelCopyWithImpl<ActivityModel>(this as ActivityModel, _$identity);

  /// Serializes this ActivityModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityModel&&(identical(other.sourceUid, sourceUid) || other.sourceUid == sourceUid)&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.commentId, commentId) || other.commentId == commentId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sourceUid,id,postId,commentId,createdAt,type);

@override
String toString() {
  return 'ActivityModel(sourceUid: $sourceUid, id: $id, postId: $postId, commentId: $commentId, createdAt: $createdAt, type: $type)';
}


}

/// @nodoc
abstract mixin class $ActivityModelCopyWith<$Res>  {
  factory $ActivityModelCopyWith(ActivityModel value, $Res Function(ActivityModel) _then) = _$ActivityModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'source_uid') String sourceUid, int id,@JsonKey(name: 'post_id') int? postId,@JsonKey(name: 'comment_id') int? commentId,@JsonKey(name: 'created_at') String createdAt, ActivityType type
});




}
/// @nodoc
class _$ActivityModelCopyWithImpl<$Res>
    implements $ActivityModelCopyWith<$Res> {
  _$ActivityModelCopyWithImpl(this._self, this._then);

  final ActivityModel _self;
  final $Res Function(ActivityModel) _then;

/// Create a copy of ActivityModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sourceUid = null,Object? id = null,Object? postId = freezed,Object? commentId = freezed,Object? createdAt = null,Object? type = null,}) {
  return _then(_self.copyWith(
sourceUid: null == sourceUid ? _self.sourceUid : sourceUid // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,postId: freezed == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as int?,commentId: freezed == commentId ? _self.commentId : commentId // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ActivityType,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivityModel].
extension ActivityModelPatterns on ActivityModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityModel value)  $default,){
final _that = this;
switch (_that) {
case _ActivityModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityModel value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'source_uid')  String sourceUid,  int id, @JsonKey(name: 'post_id')  int? postId, @JsonKey(name: 'comment_id')  int? commentId, @JsonKey(name: 'created_at')  String createdAt,  ActivityType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityModel() when $default != null:
return $default(_that.sourceUid,_that.id,_that.postId,_that.commentId,_that.createdAt,_that.type);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'source_uid')  String sourceUid,  int id, @JsonKey(name: 'post_id')  int? postId, @JsonKey(name: 'comment_id')  int? commentId, @JsonKey(name: 'created_at')  String createdAt,  ActivityType type)  $default,) {final _that = this;
switch (_that) {
case _ActivityModel():
return $default(_that.sourceUid,_that.id,_that.postId,_that.commentId,_that.createdAt,_that.type);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'source_uid')  String sourceUid,  int id, @JsonKey(name: 'post_id')  int? postId, @JsonKey(name: 'comment_id')  int? commentId, @JsonKey(name: 'created_at')  String createdAt,  ActivityType type)?  $default,) {final _that = this;
switch (_that) {
case _ActivityModel() when $default != null:
return $default(_that.sourceUid,_that.id,_that.postId,_that.commentId,_that.createdAt,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActivityModel extends ActivityModel {
  const _ActivityModel({@JsonKey(name: 'source_uid') required this.sourceUid, required this.id, @JsonKey(name: 'post_id') this.postId, @JsonKey(name: 'comment_id') this.commentId, @JsonKey(name: 'created_at') required this.createdAt, required this.type}): super._();
  factory _ActivityModel.fromJson(Map<String, dynamic> json) => _$ActivityModelFromJson(json);

@override@JsonKey(name: 'source_uid') final  String sourceUid;
@override final  int id;
@override@JsonKey(name: 'post_id') final  int? postId;
@override@JsonKey(name: 'comment_id') final  int? commentId;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override final  ActivityType type;

/// Create a copy of ActivityModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityModelCopyWith<_ActivityModel> get copyWith => __$ActivityModelCopyWithImpl<_ActivityModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActivityModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityModel&&(identical(other.sourceUid, sourceUid) || other.sourceUid == sourceUid)&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.commentId, commentId) || other.commentId == commentId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sourceUid,id,postId,commentId,createdAt,type);

@override
String toString() {
  return 'ActivityModel(sourceUid: $sourceUid, id: $id, postId: $postId, commentId: $commentId, createdAt: $createdAt, type: $type)';
}


}

/// @nodoc
abstract mixin class _$ActivityModelCopyWith<$Res> implements $ActivityModelCopyWith<$Res> {
  factory _$ActivityModelCopyWith(_ActivityModel value, $Res Function(_ActivityModel) _then) = __$ActivityModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'source_uid') String sourceUid, int id,@JsonKey(name: 'post_id') int? postId,@JsonKey(name: 'comment_id') int? commentId,@JsonKey(name: 'created_at') String createdAt, ActivityType type
});




}
/// @nodoc
class __$ActivityModelCopyWithImpl<$Res>
    implements _$ActivityModelCopyWith<$Res> {
  __$ActivityModelCopyWithImpl(this._self, this._then);

  final _ActivityModel _self;
  final $Res Function(_ActivityModel) _then;

/// Create a copy of ActivityModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sourceUid = null,Object? id = null,Object? postId = freezed,Object? commentId = freezed,Object? createdAt = null,Object? type = null,}) {
  return _then(_ActivityModel(
sourceUid: null == sourceUid ? _self.sourceUid : sourceUid // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,postId: freezed == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as int?,commentId: freezed == commentId ? _self.commentId : commentId // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ActivityType,
  ));
}


}

// dart format on
