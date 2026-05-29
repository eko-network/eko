// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../types/user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserModel {

 String get name; String get username; String get profilePicture; String get bio; String get uid; bool get isVerified; String? get verificationUrl; bool get shareOnlineStatus; bool get isFollowing;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.name, name) || other.name == name)&&(identical(other.username, username) || other.username == username)&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.verificationUrl, verificationUrl) || other.verificationUrl == verificationUrl)&&(identical(other.shareOnlineStatus, shareOnlineStatus) || other.shareOnlineStatus == shareOnlineStatus)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing));
}


@override
int get hashCode => Object.hash(runtimeType,name,username,profilePicture,bio,uid,isVerified,verificationUrl,shareOnlineStatus,isFollowing);

@override
String toString() {
  return 'UserModel(name: $name, username: $username, profilePicture: $profilePicture, bio: $bio, uid: $uid, isVerified: $isVerified, verificationUrl: $verificationUrl, shareOnlineStatus: $shareOnlineStatus, isFollowing: $isFollowing)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String name, String username, String profilePicture, String bio, String uid, bool isVerified, String? verificationUrl, bool shareOnlineStatus, bool isFollowing
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? username = null,Object? profilePicture = null,Object? bio = null,Object? uid = null,Object? isVerified = null,Object? verificationUrl = freezed,Object? shareOnlineStatus = null,Object? isFollowing = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,profilePicture: null == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,verificationUrl: freezed == verificationUrl ? _self.verificationUrl : verificationUrl // ignore: cast_nullable_to_non_nullable
as String?,shareOnlineStatus: null == shareOnlineStatus ? _self.shareOnlineStatus : shareOnlineStatus // ignore: cast_nullable_to_non_nullable
as bool,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String username,  String profilePicture,  String bio,  String uid,  bool isVerified,  String? verificationUrl,  bool shareOnlineStatus,  bool isFollowing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.name,_that.username,_that.profilePicture,_that.bio,_that.uid,_that.isVerified,_that.verificationUrl,_that.shareOnlineStatus,_that.isFollowing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String username,  String profilePicture,  String bio,  String uid,  bool isVerified,  String? verificationUrl,  bool shareOnlineStatus,  bool isFollowing)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.name,_that.username,_that.profilePicture,_that.bio,_that.uid,_that.isVerified,_that.verificationUrl,_that.shareOnlineStatus,_that.isFollowing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String username,  String profilePicture,  String bio,  String uid,  bool isVerified,  String? verificationUrl,  bool shareOnlineStatus,  bool isFollowing)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.name,_that.username,_that.profilePicture,_that.bio,_that.uid,_that.isVerified,_that.verificationUrl,_that.shareOnlineStatus,_that.isFollowing);case _:
  return null;

}
}

}

/// @nodoc


class _UserModel implements UserModel {
  const _UserModel({required this.name, required this.username, required this.profilePicture, required this.bio, required this.uid, required this.isVerified, this.verificationUrl, required this.shareOnlineStatus, this.isFollowing = false});
  

@override final  String name;
@override final  String username;
@override final  String profilePicture;
@override final  String bio;
@override final  String uid;
@override final  bool isVerified;
@override final  String? verificationUrl;
@override final  bool shareOnlineStatus;
@override@JsonKey() final  bool isFollowing;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.name, name) || other.name == name)&&(identical(other.username, username) || other.username == username)&&(identical(other.profilePicture, profilePicture) || other.profilePicture == profilePicture)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.verificationUrl, verificationUrl) || other.verificationUrl == verificationUrl)&&(identical(other.shareOnlineStatus, shareOnlineStatus) || other.shareOnlineStatus == shareOnlineStatus)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing));
}


@override
int get hashCode => Object.hash(runtimeType,name,username,profilePicture,bio,uid,isVerified,verificationUrl,shareOnlineStatus,isFollowing);

@override
String toString() {
  return 'UserModel(name: $name, username: $username, profilePicture: $profilePicture, bio: $bio, uid: $uid, isVerified: $isVerified, verificationUrl: $verificationUrl, shareOnlineStatus: $shareOnlineStatus, isFollowing: $isFollowing)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 String name, String username, String profilePicture, String bio, String uid, bool isVerified, String? verificationUrl, bool shareOnlineStatus, bool isFollowing
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? username = null,Object? profilePicture = null,Object? bio = null,Object? uid = null,Object? isVerified = null,Object? verificationUrl = freezed,Object? shareOnlineStatus = null,Object? isFollowing = null,}) {
  return _then(_UserModel(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,profilePicture: null == profilePicture ? _self.profilePicture : profilePicture // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,verificationUrl: freezed == verificationUrl ? _self.verificationUrl : verificationUrl // ignore: cast_nullable_to_non_nullable
as String?,shareOnlineStatus: null == shareOnlineStatus ? _self.shareOnlineStatus : shareOnlineStatus // ignore: cast_nullable_to_non_nullable
as bool,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
