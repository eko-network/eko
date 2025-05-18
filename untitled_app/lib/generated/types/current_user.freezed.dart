// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../types/current_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CurrentUserModel {
  UserModel get user;
  Set<String> get likedPosts;
  Set<String> get dislikedPosts;
  Set<String> get blockedUsers;
  Set<String> get blockedBy;
  Map<String, int> get pollVotes;

  /// Create a copy of CurrentUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CurrentUserModelCopyWith<CurrentUserModel> get copyWith =>
      _$CurrentUserModelCopyWithImpl<CurrentUserModel>(
          this as CurrentUserModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CurrentUserModel &&
            (identical(other.user, user) || other.user == user) &&
            const DeepCollectionEquality()
                .equals(other.likedPosts, likedPosts) &&
            const DeepCollectionEquality()
                .equals(other.dislikedPosts, dislikedPosts) &&
            const DeepCollectionEquality()
                .equals(other.blockedUsers, blockedUsers) &&
            const DeepCollectionEquality().equals(other.blockedBy, blockedBy) &&
            const DeepCollectionEquality().equals(other.pollVotes, pollVotes));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      user,
      const DeepCollectionEquality().hash(likedPosts),
      const DeepCollectionEquality().hash(dislikedPosts),
      const DeepCollectionEquality().hash(blockedUsers),
      const DeepCollectionEquality().hash(blockedBy),
      const DeepCollectionEquality().hash(pollVotes));

  @override
  String toString() {
    return 'CurrentUserModel(user: $user, likedPosts: $likedPosts, dislikedPosts: $dislikedPosts, blockedUsers: $blockedUsers, blockedBy: $blockedBy, pollVotes: $pollVotes)';
  }
}

/// @nodoc
abstract mixin class $CurrentUserModelCopyWith<$Res> {
  factory $CurrentUserModelCopyWith(
          CurrentUserModel value, $Res Function(CurrentUserModel) _then) =
      _$CurrentUserModelCopyWithImpl;
  @useResult
  $Res call(
      {UserModel user,
      Set<String> likedPosts,
      Set<String> dislikedPosts,
      Set<String> blockedUsers,
      Set<String> blockedBy,
      Map<String, int> pollVotes});

  $UserModelCopyWith<$Res> get user;
}

/// @nodoc
class _$CurrentUserModelCopyWithImpl<$Res>
    implements $CurrentUserModelCopyWith<$Res> {
  _$CurrentUserModelCopyWithImpl(this._self, this._then);

  final CurrentUserModel _self;
  final $Res Function(CurrentUserModel) _then;

  /// Create a copy of CurrentUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? likedPosts = null,
    Object? dislikedPosts = null,
    Object? blockedUsers = null,
    Object? blockedBy = null,
    Object? pollVotes = null,
  }) {
    return _then(_self.copyWith(
      user: null == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel,
      likedPosts: null == likedPosts
          ? _self.likedPosts
          : likedPosts // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      dislikedPosts: null == dislikedPosts
          ? _self.dislikedPosts
          : dislikedPosts // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      blockedUsers: null == blockedUsers
          ? _self.blockedUsers
          : blockedUsers // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      blockedBy: null == blockedBy
          ? _self.blockedBy
          : blockedBy // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      pollVotes: null == pollVotes
          ? _self.pollVotes
          : pollVotes // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }

  /// Create a copy of CurrentUserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res> get user {
    return $UserModelCopyWith<$Res>(_self.user, (value) {
      return _then(_self.copyWith(user: value));
    });
  }
}

/// @nodoc

class _CurrentUserModel implements CurrentUserModel {
  const _CurrentUserModel(
      {required this.user,
      required final Set<String> likedPosts,
      required final Set<String> dislikedPosts,
      required final Set<String> blockedUsers,
      required final Set<String> blockedBy,
      required final Map<String, int> pollVotes})
      : _likedPosts = likedPosts,
        _dislikedPosts = dislikedPosts,
        _blockedUsers = blockedUsers,
        _blockedBy = blockedBy,
        _pollVotes = pollVotes;

  @override
  final UserModel user;
  final Set<String> _likedPosts;
  @override
  Set<String> get likedPosts {
    if (_likedPosts is EqualUnmodifiableSetView) return _likedPosts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_likedPosts);
  }

  final Set<String> _dislikedPosts;
  @override
  Set<String> get dislikedPosts {
    if (_dislikedPosts is EqualUnmodifiableSetView) return _dislikedPosts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_dislikedPosts);
  }

  final Set<String> _blockedUsers;
  @override
  Set<String> get blockedUsers {
    if (_blockedUsers is EqualUnmodifiableSetView) return _blockedUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_blockedUsers);
  }

  final Set<String> _blockedBy;
  @override
  Set<String> get blockedBy {
    if (_blockedBy is EqualUnmodifiableSetView) return _blockedBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_blockedBy);
  }

  final Map<String, int> _pollVotes;
  @override
  Map<String, int> get pollVotes {
    if (_pollVotes is EqualUnmodifiableMapView) return _pollVotes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_pollVotes);
  }

  /// Create a copy of CurrentUserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CurrentUserModelCopyWith<_CurrentUserModel> get copyWith =>
      __$CurrentUserModelCopyWithImpl<_CurrentUserModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CurrentUserModel &&
            (identical(other.user, user) || other.user == user) &&
            const DeepCollectionEquality()
                .equals(other._likedPosts, _likedPosts) &&
            const DeepCollectionEquality()
                .equals(other._dislikedPosts, _dislikedPosts) &&
            const DeepCollectionEquality()
                .equals(other._blockedUsers, _blockedUsers) &&
            const DeepCollectionEquality()
                .equals(other._blockedBy, _blockedBy) &&
            const DeepCollectionEquality()
                .equals(other._pollVotes, _pollVotes));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      user,
      const DeepCollectionEquality().hash(_likedPosts),
      const DeepCollectionEquality().hash(_dislikedPosts),
      const DeepCollectionEquality().hash(_blockedUsers),
      const DeepCollectionEquality().hash(_blockedBy),
      const DeepCollectionEquality().hash(_pollVotes));

  @override
  String toString() {
    return 'CurrentUserModel(user: $user, likedPosts: $likedPosts, dislikedPosts: $dislikedPosts, blockedUsers: $blockedUsers, blockedBy: $blockedBy, pollVotes: $pollVotes)';
  }
}

/// @nodoc
abstract mixin class _$CurrentUserModelCopyWith<$Res>
    implements $CurrentUserModelCopyWith<$Res> {
  factory _$CurrentUserModelCopyWith(
          _CurrentUserModel value, $Res Function(_CurrentUserModel) _then) =
      __$CurrentUserModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {UserModel user,
      Set<String> likedPosts,
      Set<String> dislikedPosts,
      Set<String> blockedUsers,
      Set<String> blockedBy,
      Map<String, int> pollVotes});

  @override
  $UserModelCopyWith<$Res> get user;
}

/// @nodoc
class __$CurrentUserModelCopyWithImpl<$Res>
    implements _$CurrentUserModelCopyWith<$Res> {
  __$CurrentUserModelCopyWithImpl(this._self, this._then);

  final _CurrentUserModel _self;
  final $Res Function(_CurrentUserModel) _then;

  /// Create a copy of CurrentUserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? user = null,
    Object? likedPosts = null,
    Object? dislikedPosts = null,
    Object? blockedUsers = null,
    Object? blockedBy = null,
    Object? pollVotes = null,
  }) {
    return _then(_CurrentUserModel(
      user: null == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel,
      likedPosts: null == likedPosts
          ? _self._likedPosts
          : likedPosts // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      dislikedPosts: null == dislikedPosts
          ? _self._dislikedPosts
          : dislikedPosts // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      blockedUsers: null == blockedUsers
          ? _self._blockedUsers
          : blockedUsers // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      blockedBy: null == blockedBy
          ? _self._blockedBy
          : blockedBy // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      pollVotes: null == pollVotes
          ? _self._pollVotes
          : pollVotes // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }

  /// Create a copy of CurrentUserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res> get user {
    return $UserModelCopyWith<$Res>(_self.user, (value) {
      return _then(_self.copyWith(user: value));
    });
  }
}

// dart format on
