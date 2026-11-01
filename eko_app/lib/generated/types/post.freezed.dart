// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../types/post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostModel implements DiagnosticableTreeMixin {

@JsonKey(name: 'author_uid') String get uid; int get id;@JsonKey(name: 'gif') String? get gifUrl;@JsonKey(name: 'image', fromJson: _asciiImageFromString, toJson: _asciiImageToString) AsciiImage? get imageString; String? get title; String? get body; List<String> get tags;@JsonKey(name: 'like_count') int get likes;@JsonKey(name: 'dislike_count') int get dislikes;@JsonKey(name: 'comment_count') int get commentCount;@JsonKey(name: 'is_liked') bool get isLiked;@JsonKey(name: 'is_disliked') bool get isDisliked;@JsonKey(name: 'created_at') String get createdAt; List<PollOptionModel>? get poll; int? get vote;@JsonKey(name: 'ekoed_id') int? get repostId;
/// Create a copy of PostModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostModelCopyWith<PostModel> get copyWith => _$PostModelCopyWithImpl<PostModel>(this as PostModel, _$identity);

  /// Serializes this PostModel to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PostModel'))
    ..add(DiagnosticsProperty('uid', uid))..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('gifUrl', gifUrl))..add(DiagnosticsProperty('imageString', imageString))..add(DiagnosticsProperty('title', title))..add(DiagnosticsProperty('body', body))..add(DiagnosticsProperty('tags', tags))..add(DiagnosticsProperty('likes', likes))..add(DiagnosticsProperty('dislikes', dislikes))..add(DiagnosticsProperty('commentCount', commentCount))..add(DiagnosticsProperty('isLiked', isLiked))..add(DiagnosticsProperty('isDisliked', isDisliked))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('poll', poll))..add(DiagnosticsProperty('vote', vote))..add(DiagnosticsProperty('repostId', repostId));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.id, id) || other.id == id)&&(identical(other.gifUrl, gifUrl) || other.gifUrl == gifUrl)&&(identical(other.imageString, imageString) || other.imageString == imageString)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.dislikes, dislikes) || other.dislikes == dislikes)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&(identical(other.isDisliked, isDisliked) || other.isDisliked == isDisliked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.poll, poll)&&(identical(other.vote, vote) || other.vote == vote)&&(identical(other.repostId, repostId) || other.repostId == repostId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,id,gifUrl,imageString,title,body,const DeepCollectionEquality().hash(tags),likes,dislikes,commentCount,isLiked,isDisliked,createdAt,const DeepCollectionEquality().hash(poll),vote,repostId);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PostModel(uid: $uid, id: $id, gifUrl: $gifUrl, imageString: $imageString, title: $title, body: $body, tags: $tags, likes: $likes, dislikes: $dislikes, commentCount: $commentCount, isLiked: $isLiked, isDisliked: $isDisliked, createdAt: $createdAt, poll: $poll, vote: $vote, repostId: $repostId)';
}


}

/// @nodoc
abstract mixin class $PostModelCopyWith<$Res>  {
  factory $PostModelCopyWith(PostModel value, $Res Function(PostModel) _then) = _$PostModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'author_uid') String uid, int id,@JsonKey(name: 'gif') String? gifUrl,@JsonKey(name: 'image', fromJson: _asciiImageFromString, toJson: _asciiImageToString) AsciiImage? imageString, String? title, String? body, List<String> tags,@JsonKey(name: 'like_count') int likes,@JsonKey(name: 'dislike_count') int dislikes,@JsonKey(name: 'comment_count') int commentCount,@JsonKey(name: 'is_liked') bool isLiked,@JsonKey(name: 'is_disliked') bool isDisliked,@JsonKey(name: 'created_at') String createdAt, List<PollOptionModel>? poll, int? vote,@JsonKey(name: 'ekoed_id') int? repostId
});




}
/// @nodoc
class _$PostModelCopyWithImpl<$Res>
    implements $PostModelCopyWith<$Res> {
  _$PostModelCopyWithImpl(this._self, this._then);

  final PostModel _self;
  final $Res Function(PostModel) _then;

/// Create a copy of PostModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? id = null,Object? gifUrl = freezed,Object? imageString = freezed,Object? title = freezed,Object? body = freezed,Object? tags = null,Object? likes = null,Object? dislikes = null,Object? commentCount = null,Object? isLiked = null,Object? isDisliked = null,Object? createdAt = null,Object? poll = freezed,Object? vote = freezed,Object? repostId = freezed,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,gifUrl: freezed == gifUrl ? _self.gifUrl : gifUrl // ignore: cast_nullable_to_non_nullable
as String?,imageString: freezed == imageString ? _self.imageString : imageString // ignore: cast_nullable_to_non_nullable
as AsciiImage?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,dislikes: null == dislikes ? _self.dislikes : dislikes // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,isDisliked: null == isDisliked ? _self.isDisliked : isDisliked // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,poll: freezed == poll ? _self.poll : poll // ignore: cast_nullable_to_non_nullable
as List<PollOptionModel>?,vote: freezed == vote ? _self.vote : vote // ignore: cast_nullable_to_non_nullable
as int?,repostId: freezed == repostId ? _self.repostId : repostId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostModel].
extension PostModelPatterns on PostModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostModel value)  $default,){
final _that = this;
switch (_that) {
case _PostModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostModel value)?  $default,){
final _that = this;
switch (_that) {
case _PostModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'author_uid')  String uid,  int id, @JsonKey(name: 'gif')  String? gifUrl, @JsonKey(name: 'image', fromJson: _asciiImageFromString, toJson: _asciiImageToString)  AsciiImage? imageString,  String? title,  String? body,  List<String> tags, @JsonKey(name: 'like_count')  int likes, @JsonKey(name: 'dislike_count')  int dislikes, @JsonKey(name: 'comment_count')  int commentCount, @JsonKey(name: 'is_liked')  bool isLiked, @JsonKey(name: 'is_disliked')  bool isDisliked, @JsonKey(name: 'created_at')  String createdAt,  List<PollOptionModel>? poll,  int? vote, @JsonKey(name: 'ekoed_id')  int? repostId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostModel() when $default != null:
return $default(_that.uid,_that.id,_that.gifUrl,_that.imageString,_that.title,_that.body,_that.tags,_that.likes,_that.dislikes,_that.commentCount,_that.isLiked,_that.isDisliked,_that.createdAt,_that.poll,_that.vote,_that.repostId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'author_uid')  String uid,  int id, @JsonKey(name: 'gif')  String? gifUrl, @JsonKey(name: 'image', fromJson: _asciiImageFromString, toJson: _asciiImageToString)  AsciiImage? imageString,  String? title,  String? body,  List<String> tags, @JsonKey(name: 'like_count')  int likes, @JsonKey(name: 'dislike_count')  int dislikes, @JsonKey(name: 'comment_count')  int commentCount, @JsonKey(name: 'is_liked')  bool isLiked, @JsonKey(name: 'is_disliked')  bool isDisliked, @JsonKey(name: 'created_at')  String createdAt,  List<PollOptionModel>? poll,  int? vote, @JsonKey(name: 'ekoed_id')  int? repostId)  $default,) {final _that = this;
switch (_that) {
case _PostModel():
return $default(_that.uid,_that.id,_that.gifUrl,_that.imageString,_that.title,_that.body,_that.tags,_that.likes,_that.dislikes,_that.commentCount,_that.isLiked,_that.isDisliked,_that.createdAt,_that.poll,_that.vote,_that.repostId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'author_uid')  String uid,  int id, @JsonKey(name: 'gif')  String? gifUrl, @JsonKey(name: 'image', fromJson: _asciiImageFromString, toJson: _asciiImageToString)  AsciiImage? imageString,  String? title,  String? body,  List<String> tags, @JsonKey(name: 'like_count')  int likes, @JsonKey(name: 'dislike_count')  int dislikes, @JsonKey(name: 'comment_count')  int commentCount, @JsonKey(name: 'is_liked')  bool isLiked, @JsonKey(name: 'is_disliked')  bool isDisliked, @JsonKey(name: 'created_at')  String createdAt,  List<PollOptionModel>? poll,  int? vote, @JsonKey(name: 'ekoed_id')  int? repostId)?  $default,) {final _that = this;
switch (_that) {
case _PostModel() when $default != null:
return $default(_that.uid,_that.id,_that.gifUrl,_that.imageString,_that.title,_that.body,_that.tags,_that.likes,_that.dislikes,_that.commentCount,_that.isLiked,_that.isDisliked,_that.createdAt,_that.poll,_that.vote,_that.repostId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostModel extends PostModel with DiagnosticableTreeMixin {
  const _PostModel({@JsonKey(name: 'author_uid') required this.uid, required this.id, @JsonKey(name: 'gif') this.gifUrl, @JsonKey(name: 'image', fromJson: _asciiImageFromString, toJson: _asciiImageToString) this.imageString, this.title, this.body, final  List<String> tags = const ['public'], @JsonKey(name: 'like_count') this.likes = 0, @JsonKey(name: 'dislike_count') this.dislikes = 0, @JsonKey(name: 'comment_count') this.commentCount = 0, @JsonKey(name: 'is_liked') this.isLiked = false, @JsonKey(name: 'is_disliked') this.isDisliked = false, @JsonKey(name: 'created_at') required this.createdAt, final  List<PollOptionModel>? poll, this.vote, @JsonKey(name: 'ekoed_id') this.repostId}): _tags = tags,_poll = poll,super._();
  factory _PostModel.fromJson(Map<String, dynamic> json) => _$PostModelFromJson(json);

@override@JsonKey(name: 'author_uid') final  String uid;
@override final  int id;
@override@JsonKey(name: 'gif') final  String? gifUrl;
@override@JsonKey(name: 'image', fromJson: _asciiImageFromString, toJson: _asciiImageToString) final  AsciiImage? imageString;
@override final  String? title;
@override final  String? body;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey(name: 'like_count') final  int likes;
@override@JsonKey(name: 'dislike_count') final  int dislikes;
@override@JsonKey(name: 'comment_count') final  int commentCount;
@override@JsonKey(name: 'is_liked') final  bool isLiked;
@override@JsonKey(name: 'is_disliked') final  bool isDisliked;
@override@JsonKey(name: 'created_at') final  String createdAt;
 final  List<PollOptionModel>? _poll;
@override List<PollOptionModel>? get poll {
  final value = _poll;
  if (value == null) return null;
  if (_poll is EqualUnmodifiableListView) return _poll;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  int? vote;
@override@JsonKey(name: 'ekoed_id') final  int? repostId;

/// Create a copy of PostModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostModelCopyWith<_PostModel> get copyWith => __$PostModelCopyWithImpl<_PostModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostModelToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PostModel'))
    ..add(DiagnosticsProperty('uid', uid))..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('gifUrl', gifUrl))..add(DiagnosticsProperty('imageString', imageString))..add(DiagnosticsProperty('title', title))..add(DiagnosticsProperty('body', body))..add(DiagnosticsProperty('tags', tags))..add(DiagnosticsProperty('likes', likes))..add(DiagnosticsProperty('dislikes', dislikes))..add(DiagnosticsProperty('commentCount', commentCount))..add(DiagnosticsProperty('isLiked', isLiked))..add(DiagnosticsProperty('isDisliked', isDisliked))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('poll', poll))..add(DiagnosticsProperty('vote', vote))..add(DiagnosticsProperty('repostId', repostId));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.id, id) || other.id == id)&&(identical(other.gifUrl, gifUrl) || other.gifUrl == gifUrl)&&(identical(other.imageString, imageString) || other.imageString == imageString)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.dislikes, dislikes) || other.dislikes == dislikes)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&(identical(other.isDisliked, isDisliked) || other.isDisliked == isDisliked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._poll, _poll)&&(identical(other.vote, vote) || other.vote == vote)&&(identical(other.repostId, repostId) || other.repostId == repostId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,id,gifUrl,imageString,title,body,const DeepCollectionEquality().hash(_tags),likes,dislikes,commentCount,isLiked,isDisliked,createdAt,const DeepCollectionEquality().hash(_poll),vote,repostId);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PostModel(uid: $uid, id: $id, gifUrl: $gifUrl, imageString: $imageString, title: $title, body: $body, tags: $tags, likes: $likes, dislikes: $dislikes, commentCount: $commentCount, isLiked: $isLiked, isDisliked: $isDisliked, createdAt: $createdAt, poll: $poll, vote: $vote, repostId: $repostId)';
}


}

/// @nodoc
abstract mixin class _$PostModelCopyWith<$Res> implements $PostModelCopyWith<$Res> {
  factory _$PostModelCopyWith(_PostModel value, $Res Function(_PostModel) _then) = __$PostModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'author_uid') String uid, int id,@JsonKey(name: 'gif') String? gifUrl,@JsonKey(name: 'image', fromJson: _asciiImageFromString, toJson: _asciiImageToString) AsciiImage? imageString, String? title, String? body, List<String> tags,@JsonKey(name: 'like_count') int likes,@JsonKey(name: 'dislike_count') int dislikes,@JsonKey(name: 'comment_count') int commentCount,@JsonKey(name: 'is_liked') bool isLiked,@JsonKey(name: 'is_disliked') bool isDisliked,@JsonKey(name: 'created_at') String createdAt, List<PollOptionModel>? poll, int? vote,@JsonKey(name: 'ekoed_id') int? repostId
});




}
/// @nodoc
class __$PostModelCopyWithImpl<$Res>
    implements _$PostModelCopyWith<$Res> {
  __$PostModelCopyWithImpl(this._self, this._then);

  final _PostModel _self;
  final $Res Function(_PostModel) _then;

/// Create a copy of PostModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? id = null,Object? gifUrl = freezed,Object? imageString = freezed,Object? title = freezed,Object? body = freezed,Object? tags = null,Object? likes = null,Object? dislikes = null,Object? commentCount = null,Object? isLiked = null,Object? isDisliked = null,Object? createdAt = null,Object? poll = freezed,Object? vote = freezed,Object? repostId = freezed,}) {
  return _then(_PostModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,gifUrl: freezed == gifUrl ? _self.gifUrl : gifUrl // ignore: cast_nullable_to_non_nullable
as String?,imageString: freezed == imageString ? _self.imageString : imageString // ignore: cast_nullable_to_non_nullable
as AsciiImage?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,dislikes: null == dislikes ? _self.dislikes : dislikes // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,isDisliked: null == isDisliked ? _self.isDisliked : isDisliked // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,poll: freezed == poll ? _self._poll : poll // ignore: cast_nullable_to_non_nullable
as List<PollOptionModel>?,vote: freezed == vote ? _self.vote : vote // ignore: cast_nullable_to_non_nullable
as int?,repostId: freezed == repostId ? _self.repostId : repostId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$PollOptionModel implements DiagnosticableTreeMixin {

 String get value;@JsonKey(name: 'option_id') int get optionId;@JsonKey(name: 'vote_count') int get voteCount;
/// Create a copy of PollOptionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PollOptionModelCopyWith<PollOptionModel> get copyWith => _$PollOptionModelCopyWithImpl<PollOptionModel>(this as PollOptionModel, _$identity);

  /// Serializes this PollOptionModel to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PollOptionModel'))
    ..add(DiagnosticsProperty('value', value))..add(DiagnosticsProperty('optionId', optionId))..add(DiagnosticsProperty('voteCount', voteCount));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PollOptionModel&&(identical(other.value, value) || other.value == value)&&(identical(other.optionId, optionId) || other.optionId == optionId)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,optionId,voteCount);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PollOptionModel(value: $value, optionId: $optionId, voteCount: $voteCount)';
}


}

/// @nodoc
abstract mixin class $PollOptionModelCopyWith<$Res>  {
  factory $PollOptionModelCopyWith(PollOptionModel value, $Res Function(PollOptionModel) _then) = _$PollOptionModelCopyWithImpl;
@useResult
$Res call({
 String value,@JsonKey(name: 'option_id') int optionId,@JsonKey(name: 'vote_count') int voteCount
});




}
/// @nodoc
class _$PollOptionModelCopyWithImpl<$Res>
    implements $PollOptionModelCopyWith<$Res> {
  _$PollOptionModelCopyWithImpl(this._self, this._then);

  final PollOptionModel _self;
  final $Res Function(PollOptionModel) _then;

/// Create a copy of PollOptionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? optionId = null,Object? voteCount = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,optionId: null == optionId ? _self.optionId : optionId // ignore: cast_nullable_to_non_nullable
as int,voteCount: null == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PollOptionModel].
extension PollOptionModelPatterns on PollOptionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PollOptionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PollOptionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PollOptionModel value)  $default,){
final _that = this;
switch (_that) {
case _PollOptionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PollOptionModel value)?  $default,){
final _that = this;
switch (_that) {
case _PollOptionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value, @JsonKey(name: 'option_id')  int optionId, @JsonKey(name: 'vote_count')  int voteCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PollOptionModel() when $default != null:
return $default(_that.value,_that.optionId,_that.voteCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value, @JsonKey(name: 'option_id')  int optionId, @JsonKey(name: 'vote_count')  int voteCount)  $default,) {final _that = this;
switch (_that) {
case _PollOptionModel():
return $default(_that.value,_that.optionId,_that.voteCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value, @JsonKey(name: 'option_id')  int optionId, @JsonKey(name: 'vote_count')  int voteCount)?  $default,) {final _that = this;
switch (_that) {
case _PollOptionModel() when $default != null:
return $default(_that.value,_that.optionId,_that.voteCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PollOptionModel with DiagnosticableTreeMixin implements PollOptionModel {
  const _PollOptionModel({required this.value, @JsonKey(name: 'option_id') required this.optionId, @JsonKey(name: 'vote_count') required this.voteCount});
  factory _PollOptionModel.fromJson(Map<String, dynamic> json) => _$PollOptionModelFromJson(json);

@override final  String value;
@override@JsonKey(name: 'option_id') final  int optionId;
@override@JsonKey(name: 'vote_count') final  int voteCount;

/// Create a copy of PollOptionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PollOptionModelCopyWith<_PollOptionModel> get copyWith => __$PollOptionModelCopyWithImpl<_PollOptionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PollOptionModelToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PollOptionModel'))
    ..add(DiagnosticsProperty('value', value))..add(DiagnosticsProperty('optionId', optionId))..add(DiagnosticsProperty('voteCount', voteCount));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PollOptionModel&&(identical(other.value, value) || other.value == value)&&(identical(other.optionId, optionId) || other.optionId == optionId)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,optionId,voteCount);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PollOptionModel(value: $value, optionId: $optionId, voteCount: $voteCount)';
}


}

/// @nodoc
abstract mixin class _$PollOptionModelCopyWith<$Res> implements $PollOptionModelCopyWith<$Res> {
  factory _$PollOptionModelCopyWith(_PollOptionModel value, $Res Function(_PollOptionModel) _then) = __$PollOptionModelCopyWithImpl;
@override @useResult
$Res call({
 String value,@JsonKey(name: 'option_id') int optionId,@JsonKey(name: 'vote_count') int voteCount
});




}
/// @nodoc
class __$PollOptionModelCopyWithImpl<$Res>
    implements _$PollOptionModelCopyWith<$Res> {
  __$PollOptionModelCopyWithImpl(this._self, this._then);

  final _PollOptionModel _self;
  final $Res Function(_PollOptionModel) _then;

/// Create a copy of PollOptionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? optionId = null,Object? voteCount = null,}) {
  return _then(_PollOptionModel(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,optionId: null == optionId ? _self.optionId : optionId // ignore: cast_nullable_to_non_nullable
as int,voteCount: null == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
