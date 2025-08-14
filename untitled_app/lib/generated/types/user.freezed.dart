// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
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
  String get name;
  String get username;
  @JsonKey(
      name: 'profile_picture',
      defaultValue:
          'https://firebasestorage.googleapis.com/v0/b/untitled-2832f.appspot.com/o/profile_pictures%2Fdefault%2Fprofile.jpg?alt=media&token=2543c4eb-f991-468f-9ce8-68c576ffca7c')
  String get profilePicture;
  @JsonKey(defaultValue: '')
  String get bio;
  @JsonKey(name: 'id')
  String get uid;
  @JsonKey(name: 'is_verified', defaultValue: false)
  bool get isVerified;
  @JsonKey(name: 'is_following', defaultValue: false)
  bool get isFollowing;
  @JsonKey(name: 'is_follower', defaultValue: false)
  bool get isFollower;
  @JsonKey(name: 'share_online_status', defaultValue: true)
  bool get shareOnlineStatus;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<UserModel> get copyWith =>
      _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserModel &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.isFollowing, isFollowing) ||
                other.isFollowing == isFollowing) &&
            (identical(other.isFollower, isFollower) ||
                other.isFollower == isFollower) &&
            (identical(other.shareOnlineStatus, shareOnlineStatus) ||
                other.shareOnlineStatus == shareOnlineStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, username, profilePicture,
      bio, uid, isVerified, isFollowing, isFollower, shareOnlineStatus);

  @override
  String toString() {
    return 'UserModel(name: $name, username: $username, profilePicture: $profilePicture, bio: $bio, uid: $uid, isVerified: $isVerified, isFollowing: $isFollowing, isFollower: $isFollower, shareOnlineStatus: $shareOnlineStatus)';
  }
}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) =
      _$UserModelCopyWithImpl;
  @useResult
  $Res call(
      {String name,
      String username,
      @JsonKey(
          name: 'profile_picture',
          defaultValue:
              'https://firebasestorage.googleapis.com/v0/b/untitled-2832f.appspot.com/o/profile_pictures%2Fdefault%2Fprofile.jpg?alt=media&token=2543c4eb-f991-468f-9ce8-68c576ffca7c')
      String profilePicture,
      @JsonKey(defaultValue: '') String bio,
      @JsonKey(name: 'id') String uid,
      @JsonKey(name: 'is_verified', defaultValue: false) bool isVerified,
      @JsonKey(name: 'is_following', defaultValue: false) bool isFollowing,
      @JsonKey(name: 'is_follower', defaultValue: false) bool isFollower,
      @JsonKey(name: 'share_online_status', defaultValue: true)
      bool shareOnlineStatus});
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res> implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? username = null,
    Object? profilePicture = null,
    Object? bio = null,
    Object? uid = null,
    Object? isVerified = null,
    Object? isFollowing = null,
    Object? isFollower = null,
    Object? shareOnlineStatus = null,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _self.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      profilePicture: null == profilePicture
          ? _self.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _self.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      isVerified: null == isVerified
          ? _self.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isFollowing: null == isFollowing
          ? _self.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      isFollower: null == isFollower
          ? _self.isFollower
          : isFollower // ignore: cast_nullable_to_non_nullable
              as bool,
      shareOnlineStatus: null == shareOnlineStatus
          ? _self.shareOnlineStatus
          : shareOnlineStatus // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _UserModel implements UserModel {
  const _UserModel(
      {this.name = '',
      required this.username,
      @JsonKey(
          name: 'profile_picture',
          defaultValue:
              'https://firebasestorage.googleapis.com/v0/b/untitled-2832f.appspot.com/o/profile_pictures%2Fdefault%2Fprofile.jpg?alt=media&token=2543c4eb-f991-468f-9ce8-68c576ffca7c')
      required this.profilePicture,
      @JsonKey(defaultValue: '') required this.bio,
      @JsonKey(name: 'id') required this.uid,
      @JsonKey(name: 'is_verified', defaultValue: false)
      required this.isVerified,
      @JsonKey(name: 'is_following', defaultValue: false)
      required this.isFollowing,
      @JsonKey(name: 'is_follower', defaultValue: false)
      required this.isFollower,
      @JsonKey(name: 'share_online_status', defaultValue: true)
      required this.shareOnlineStatus});
  factory _UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  @override
  @JsonKey()
  final String name;
  @override
  final String username;
  @override
  @JsonKey(
      name: 'profile_picture',
      defaultValue:
          'https://firebasestorage.googleapis.com/v0/b/untitled-2832f.appspot.com/o/profile_pictures%2Fdefault%2Fprofile.jpg?alt=media&token=2543c4eb-f991-468f-9ce8-68c576ffca7c')
  final String profilePicture;
  @override
  @JsonKey(defaultValue: '')
  final String bio;
  @override
  @JsonKey(name: 'id')
  final String uid;
  @override
  @JsonKey(name: 'is_verified', defaultValue: false)
  final bool isVerified;
  @override
  @JsonKey(name: 'is_following', defaultValue: false)
  final bool isFollowing;
  @override
  @JsonKey(name: 'is_follower', defaultValue: false)
  final bool isFollower;
  @override
  @JsonKey(name: 'share_online_status', defaultValue: true)
  final bool shareOnlineStatus;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserModelCopyWith<_UserModel> get copyWith =>
      __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UserModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserModel &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.isFollowing, isFollowing) ||
                other.isFollowing == isFollowing) &&
            (identical(other.isFollower, isFollower) ||
                other.isFollower == isFollower) &&
            (identical(other.shareOnlineStatus, shareOnlineStatus) ||
                other.shareOnlineStatus == shareOnlineStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, username, profilePicture,
      bio, uid, isVerified, isFollowing, isFollower, shareOnlineStatus);

  @override
  String toString() {
    return 'UserModel(name: $name, username: $username, profilePicture: $profilePicture, bio: $bio, uid: $uid, isVerified: $isVerified, isFollowing: $isFollowing, isFollower: $isFollower, shareOnlineStatus: $shareOnlineStatus)';
  }
}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(
          _UserModel value, $Res Function(_UserModel) _then) =
      __$UserModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String name,
      String username,
      @JsonKey(
          name: 'profile_picture',
          defaultValue:
              'https://firebasestorage.googleapis.com/v0/b/untitled-2832f.appspot.com/o/profile_pictures%2Fdefault%2Fprofile.jpg?alt=media&token=2543c4eb-f991-468f-9ce8-68c576ffca7c')
      String profilePicture,
      @JsonKey(defaultValue: '') String bio,
      @JsonKey(name: 'id') String uid,
      @JsonKey(name: 'is_verified', defaultValue: false) bool isVerified,
      @JsonKey(name: 'is_following', defaultValue: false) bool isFollowing,
      @JsonKey(name: 'is_follower', defaultValue: false) bool isFollower,
      @JsonKey(name: 'share_online_status', defaultValue: true)
      bool shareOnlineStatus});
}

/// @nodoc
class __$UserModelCopyWithImpl<$Res> implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? username = null,
    Object? profilePicture = null,
    Object? bio = null,
    Object? uid = null,
    Object? isVerified = null,
    Object? isFollowing = null,
    Object? isFollower = null,
    Object? shareOnlineStatus = null,
  }) {
    return _then(_UserModel(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _self.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      profilePicture: null == profilePicture
          ? _self.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _self.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      isVerified: null == isVerified
          ? _self.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isFollowing: null == isFollowing
          ? _self.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      isFollower: null == isFollower
          ? _self.isFollower
          : isFollower // ignore: cast_nullable_to_non_nullable
              as bool,
      shareOnlineStatus: null == shareOnlineStatus
          ? _self.shareOnlineStatus
          : shareOnlineStatus // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
