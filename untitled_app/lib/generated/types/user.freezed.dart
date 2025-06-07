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
  String get profilePicture;
  String get bio;
  List<String> get followers;
  List<String> get following;
  String get uid;
  bool get isVerified;
  @JsonKey(name: 'share_online_status')
  bool get shareOnlineStatus;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<UserModel> get copyWith =>
      _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

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
            const DeepCollectionEquality().equals(other.followers, followers) &&
            const DeepCollectionEquality().equals(other.following, following) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.shareOnlineStatus, shareOnlineStatus) ||
                other.shareOnlineStatus == shareOnlineStatus));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      username,
      profilePicture,
      bio,
      const DeepCollectionEquality().hash(followers),
      const DeepCollectionEquality().hash(following),
      uid,
      isVerified,
      shareOnlineStatus);

  @override
  String toString() {
    return 'UserModel(name: $name, username: $username, profilePicture: $profilePicture, bio: $bio, followers: $followers, following: $following, uid: $uid, isVerified: $isVerified, shareOnlineStatus: $shareOnlineStatus)';
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
      String profilePicture,
      String bio,
      List<String> followers,
      List<String> following,
      String uid,
      bool isVerified,
      @JsonKey(name: 'share_online_status') bool shareOnlineStatus});
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
    Object? followers = null,
    Object? following = null,
    Object? uid = null,
    Object? isVerified = null,
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
      followers: null == followers
          ? _self.followers
          : followers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      following: null == following
          ? _self.following
          : following // ignore: cast_nullable_to_non_nullable
              as List<String>,
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      isVerified: null == isVerified
          ? _self.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
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
      {required this.name,
      required this.username,
      required this.profilePicture,
      required this.bio,
      required final List<String> followers,
      required final List<String> following,
      required this.uid,
      required this.isVerified,
      @JsonKey(name: 'share_online_status') required this.shareOnlineStatus})
      : _followers = followers,
        _following = following;

  @override
  final String name;
  @override
  final String username;
  @override
  final String profilePicture;
  @override
  final String bio;
  final List<String> _followers;
  @override
  List<String> get followers {
    if (_followers is EqualUnmodifiableListView) return _followers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_followers);
  }

  final List<String> _following;
  @override
  List<String> get following {
    if (_following is EqualUnmodifiableListView) return _following;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_following);
  }

  @override
  final String uid;
  @override
  final bool isVerified;
  @override
  @JsonKey(name: 'share_online_status')
  final bool shareOnlineStatus;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserModelCopyWith<_UserModel> get copyWith =>
      __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

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
            const DeepCollectionEquality()
                .equals(other._followers, _followers) &&
            const DeepCollectionEquality()
                .equals(other._following, _following) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.shareOnlineStatus, shareOnlineStatus) ||
                other.shareOnlineStatus == shareOnlineStatus));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      username,
      profilePicture,
      bio,
      const DeepCollectionEquality().hash(_followers),
      const DeepCollectionEquality().hash(_following),
      uid,
      isVerified,
      shareOnlineStatus);

  @override
  String toString() {
    return 'UserModel(name: $name, username: $username, profilePicture: $profilePicture, bio: $bio, followers: $followers, following: $following, uid: $uid, isVerified: $isVerified, shareOnlineStatus: $shareOnlineStatus)';
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
      String profilePicture,
      String bio,
      List<String> followers,
      List<String> following,
      String uid,
      bool isVerified,
      @JsonKey(name: 'share_online_status') bool shareOnlineStatus});
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
    Object? followers = null,
    Object? following = null,
    Object? uid = null,
    Object? isVerified = null,
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
      followers: null == followers
          ? _self._followers
          : followers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      following: null == following
          ? _self._following
          : following // ignore: cast_nullable_to_non_nullable
              as List<String>,
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      isVerified: null == isVerified
          ? _self.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      shareOnlineStatus: null == shareOnlineStatus
          ? _self.shareOnlineStatus
          : shareOnlineStatus // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
