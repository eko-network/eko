// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../types/comment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommentModel {

@JsonKey(name: 'author_uid') String get uid; int get id;@JsonKey(name: 'parent_post_id') int get postId;@JsonKey(name: 'gif') String? get gifUrl; String? get body;@JsonKey(name: 'like_count') int get likes;@JsonKey(name: 'dislike_count') int get dislikes;@JsonKey(name: 'is_liked') bool get isLiked;@JsonKey(name: 'is_disliked') bool get isDisliked;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of CommentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentModelCopyWith<CommentModel> get copyWith => _$CommentModelCopyWithImpl<CommentModel>(this as CommentModel, _$identity);

  /// Serializes this CommentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.gifUrl, gifUrl) || other.gifUrl == gifUrl)&&(identical(other.body, body) || other.body == body)&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.dislikes, dislikes) || other.dislikes == dislikes)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&(identical(other.isDisliked, isDisliked) || other.isDisliked == isDisliked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,id,postId,gifUrl,body,likes,dislikes,isLiked,isDisliked,createdAt);

@override
String toString() {
  return 'CommentModel(uid: $uid, id: $id, postId: $postId, gifUrl: $gifUrl, body: $body, likes: $likes, dislikes: $dislikes, isLiked: $isLiked, isDisliked: $isDisliked, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CommentModelCopyWith<$Res>  {
  factory $CommentModelCopyWith(CommentModel value, $Res Function(CommentModel) _then) = _$CommentModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'author_uid') String uid, int id,@JsonKey(name: 'parent_post_id') int postId,@JsonKey(name: 'gif') String? gifUrl, String? body,@JsonKey(name: 'like_count') int likes,@JsonKey(name: 'dislike_count') int dislikes,@JsonKey(name: 'is_liked') bool isLiked,@JsonKey(name: 'is_disliked') bool isDisliked,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class _$CommentModelCopyWithImpl<$Res>
    implements $CommentModelCopyWith<$Res> {
  _$CommentModelCopyWithImpl(this._self, this._then);

  final CommentModel _self;
  final $Res Function(CommentModel) _then;

/// Create a copy of CommentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? id = null,Object? postId = null,Object? gifUrl = freezed,Object? body = freezed,Object? likes = null,Object? dislikes = null,Object? isLiked = null,Object? isDisliked = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as int,gifUrl: freezed == gifUrl ? _self.gifUrl : gifUrl // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,dislikes: null == dislikes ? _self.dislikes : dislikes // ignore: cast_nullable_to_non_nullable
as int,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,isDisliked: null == isDisliked ? _self.isDisliked : isDisliked // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CommentModel].
extension CommentModelPatterns on CommentModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentModel value)  $default,){
final _that = this;
switch (_that) {
case _CommentModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentModel value)?  $default,){
final _that = this;
switch (_that) {
case _CommentModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'author_uid')  String uid,  int id, @JsonKey(name: 'parent_post_id')  int postId, @JsonKey(name: 'gif')  String? gifUrl,  String? body, @JsonKey(name: 'like_count')  int likes, @JsonKey(name: 'dislike_count')  int dislikes, @JsonKey(name: 'is_liked')  bool isLiked, @JsonKey(name: 'is_disliked')  bool isDisliked, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentModel() when $default != null:
return $default(_that.uid,_that.id,_that.postId,_that.gifUrl,_that.body,_that.likes,_that.dislikes,_that.isLiked,_that.isDisliked,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'author_uid')  String uid,  int id, @JsonKey(name: 'parent_post_id')  int postId, @JsonKey(name: 'gif')  String? gifUrl,  String? body, @JsonKey(name: 'like_count')  int likes, @JsonKey(name: 'dislike_count')  int dislikes, @JsonKey(name: 'is_liked')  bool isLiked, @JsonKey(name: 'is_disliked')  bool isDisliked, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _CommentModel():
return $default(_that.uid,_that.id,_that.postId,_that.gifUrl,_that.body,_that.likes,_that.dislikes,_that.isLiked,_that.isDisliked,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'author_uid')  String uid,  int id, @JsonKey(name: 'parent_post_id')  int postId, @JsonKey(name: 'gif')  String? gifUrl,  String? body, @JsonKey(name: 'like_count')  int likes, @JsonKey(name: 'dislike_count')  int dislikes, @JsonKey(name: 'is_liked')  bool isLiked, @JsonKey(name: 'is_disliked')  bool isDisliked, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CommentModel() when $default != null:
return $default(_that.uid,_that.id,_that.postId,_that.gifUrl,_that.body,_that.likes,_that.dislikes,_that.isLiked,_that.isDisliked,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommentModel extends CommentModel {
  const _CommentModel({@JsonKey(name: 'author_uid') required this.uid, required this.id, @JsonKey(name: 'parent_post_id') required this.postId, @JsonKey(name: 'gif') this.gifUrl, this.body, @JsonKey(name: 'like_count') this.likes = 0, @JsonKey(name: 'dislike_count') this.dislikes = 0, @JsonKey(name: 'is_liked') this.isLiked = false, @JsonKey(name: 'is_disliked') this.isDisliked = false, @JsonKey(name: 'created_at') required this.createdAt}): super._();
  factory _CommentModel.fromJson(Map<String, dynamic> json) => _$CommentModelFromJson(json);

@override@JsonKey(name: 'author_uid') final  String uid;
@override final  int id;
@override@JsonKey(name: 'parent_post_id') final  int postId;
@override@JsonKey(name: 'gif') final  String? gifUrl;
@override final  String? body;
@override@JsonKey(name: 'like_count') final  int likes;
@override@JsonKey(name: 'dislike_count') final  int dislikes;
@override@JsonKey(name: 'is_liked') final  bool isLiked;
@override@JsonKey(name: 'is_disliked') final  bool isDisliked;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of CommentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentModelCopyWith<_CommentModel> get copyWith => __$CommentModelCopyWithImpl<_CommentModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommentModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.gifUrl, gifUrl) || other.gifUrl == gifUrl)&&(identical(other.body, body) || other.body == body)&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.dislikes, dislikes) || other.dislikes == dislikes)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&(identical(other.isDisliked, isDisliked) || other.isDisliked == isDisliked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,id,postId,gifUrl,body,likes,dislikes,isLiked,isDisliked,createdAt);

@override
String toString() {
  return 'CommentModel(uid: $uid, id: $id, postId: $postId, gifUrl: $gifUrl, body: $body, likes: $likes, dislikes: $dislikes, isLiked: $isLiked, isDisliked: $isDisliked, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CommentModelCopyWith<$Res> implements $CommentModelCopyWith<$Res> {
  factory _$CommentModelCopyWith(_CommentModel value, $Res Function(_CommentModel) _then) = __$CommentModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'author_uid') String uid, int id,@JsonKey(name: 'parent_post_id') int postId,@JsonKey(name: 'gif') String? gifUrl, String? body,@JsonKey(name: 'like_count') int likes,@JsonKey(name: 'dislike_count') int dislikes,@JsonKey(name: 'is_liked') bool isLiked,@JsonKey(name: 'is_disliked') bool isDisliked,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class __$CommentModelCopyWithImpl<$Res>
    implements _$CommentModelCopyWith<$Res> {
  __$CommentModelCopyWithImpl(this._self, this._then);

  final _CommentModel _self;
  final $Res Function(_CommentModel) _then;

/// Create a copy of CommentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? id = null,Object? postId = null,Object? gifUrl = freezed,Object? body = freezed,Object? likes = null,Object? dislikes = null,Object? isLiked = null,Object? isDisliked = null,Object? createdAt = null,}) {
  return _then(_CommentModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as int,gifUrl: freezed == gifUrl ? _self.gifUrl : gifUrl // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,dislikes: null == dislikes ? _self.dislikes : dislikes // ignore: cast_nullable_to_non_nullable
as int,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,isDisliked: null == isDisliked ? _self.isDisliked : isDisliked // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
