// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../../types/post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostModel {
  String get uid;
  String get id;
  String? get gifUrl;
  String? get imageString;
  List<String>? get title;
  List<String>? get body;
  List<String> get tags;
  int get likes;
  int get dislikes;
  int get commentCount;
  String get createdAt;
  bool get isPoll;
  List<String>? get pollOptions;
  Map<String, int>? get pollVoteCounts;

  /// Create a copy of PostModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PostModelCopyWith<PostModel> get copyWith =>
      _$PostModelCopyWithImpl<PostModel>(this as PostModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PostModel &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gifUrl, gifUrl) || other.gifUrl == gifUrl) &&
            (identical(other.imageString, imageString) ||
                other.imageString == imageString) &&
            const DeepCollectionEquality().equals(other.title, title) &&
            const DeepCollectionEquality().equals(other.body, body) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            (identical(other.likes, likes) || other.likes == likes) &&
            (identical(other.dislikes, dislikes) ||
                other.dislikes == dislikes) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isPoll, isPoll) || other.isPoll == isPoll) &&
            const DeepCollectionEquality()
                .equals(other.pollOptions, pollOptions) &&
            const DeepCollectionEquality()
                .equals(other.pollVoteCounts, pollVoteCounts));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      uid,
      id,
      gifUrl,
      imageString,
      const DeepCollectionEquality().hash(title),
      const DeepCollectionEquality().hash(body),
      const DeepCollectionEquality().hash(tags),
      likes,
      dislikes,
      commentCount,
      createdAt,
      isPoll,
      const DeepCollectionEquality().hash(pollOptions),
      const DeepCollectionEquality().hash(pollVoteCounts));

  @override
  String toString() {
    return 'PostModel(uid: $uid, id: $id, gifUrl: $gifUrl, imageString: $imageString, title: $title, body: $body, tags: $tags, likes: $likes, dislikes: $dislikes, commentCount: $commentCount, createdAt: $createdAt, isPoll: $isPoll, pollOptions: $pollOptions, pollVoteCounts: $pollVoteCounts)';
  }
}

/// @nodoc
abstract mixin class $PostModelCopyWith<$Res> {
  factory $PostModelCopyWith(PostModel value, $Res Function(PostModel) _then) =
      _$PostModelCopyWithImpl;
  @useResult
  $Res call(
      {String uid,
      String id,
      String? gifUrl,
      String? imageString,
      List<String>? title,
      List<String>? body,
      List<String> tags,
      int likes,
      int dislikes,
      int commentCount,
      String createdAt,
      bool isPoll,
      List<String>? pollOptions,
      Map<String, int>? pollVoteCounts});
}

/// @nodoc
class _$PostModelCopyWithImpl<$Res> implements $PostModelCopyWith<$Res> {
  _$PostModelCopyWithImpl(this._self, this._then);

  final PostModel _self;
  final $Res Function(PostModel) _then;

  /// Create a copy of PostModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? id = null,
    Object? gifUrl = freezed,
    Object? imageString = freezed,
    Object? title = freezed,
    Object? body = freezed,
    Object? tags = null,
    Object? likes = null,
    Object? dislikes = null,
    Object? commentCount = null,
    Object? createdAt = null,
    Object? isPoll = null,
    Object? pollOptions = freezed,
    Object? pollVoteCounts = freezed,
  }) {
    return _then(_self.copyWith(
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      gifUrl: freezed == gifUrl
          ? _self.gifUrl
          : gifUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageString: freezed == imageString
          ? _self.imageString
          : imageString // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      body: freezed == body
          ? _self.body
          : body // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      tags: null == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      likes: null == likes
          ? _self.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as int,
      dislikes: null == dislikes
          ? _self.dislikes
          : dislikes // ignore: cast_nullable_to_non_nullable
              as int,
      commentCount: null == commentCount
          ? _self.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      isPoll: null == isPoll
          ? _self.isPoll
          : isPoll // ignore: cast_nullable_to_non_nullable
              as bool,
      pollOptions: freezed == pollOptions
          ? _self.pollOptions
          : pollOptions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      pollVoteCounts: freezed == pollVoteCounts
          ? _self.pollVoteCounts
          : pollVoteCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _PostModel implements PostModel {
  const _PostModel(
      {required this.uid,
      required this.id,
      this.gifUrl,
      this.imageString,
      final List<String>? title,
      final List<String>? body,
      required final List<String> tags,
      required this.likes,
      required this.dislikes,
      required this.commentCount,
      required this.createdAt,
      required this.isPoll,
      final List<String>? pollOptions,
      final Map<String, int>? pollVoteCounts})
      : _title = title,
        _body = body,
        _tags = tags,
        _pollOptions = pollOptions,
        _pollVoteCounts = pollVoteCounts;

  @override
  final String uid;
  @override
  final String id;
  @override
  final String? gifUrl;
  @override
  final String? imageString;
  final List<String>? _title;
  @override
  List<String>? get title {
    final value = _title;
    if (value == null) return null;
    if (_title is EqualUnmodifiableListView) return _title;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _body;
  @override
  List<String>? get body {
    final value = _body;
    if (value == null) return null;
    if (_body is EqualUnmodifiableListView) return _body;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final int likes;
  @override
  final int dislikes;
  @override
  final int commentCount;
  @override
  final String createdAt;
  @override
  final bool isPoll;
  final List<String>? _pollOptions;
  @override
  List<String>? get pollOptions {
    final value = _pollOptions;
    if (value == null) return null;
    if (_pollOptions is EqualUnmodifiableListView) return _pollOptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, int>? _pollVoteCounts;
  @override
  Map<String, int>? get pollVoteCounts {
    final value = _pollVoteCounts;
    if (value == null) return null;
    if (_pollVoteCounts is EqualUnmodifiableMapView) return _pollVoteCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of PostModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PostModelCopyWith<_PostModel> get copyWith =>
      __$PostModelCopyWithImpl<_PostModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PostModel &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gifUrl, gifUrl) || other.gifUrl == gifUrl) &&
            (identical(other.imageString, imageString) ||
                other.imageString == imageString) &&
            const DeepCollectionEquality().equals(other._title, _title) &&
            const DeepCollectionEquality().equals(other._body, _body) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.likes, likes) || other.likes == likes) &&
            (identical(other.dislikes, dislikes) ||
                other.dislikes == dislikes) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isPoll, isPoll) || other.isPoll == isPoll) &&
            const DeepCollectionEquality()
                .equals(other._pollOptions, _pollOptions) &&
            const DeepCollectionEquality()
                .equals(other._pollVoteCounts, _pollVoteCounts));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      uid,
      id,
      gifUrl,
      imageString,
      const DeepCollectionEquality().hash(_title),
      const DeepCollectionEquality().hash(_body),
      const DeepCollectionEquality().hash(_tags),
      likes,
      dislikes,
      commentCount,
      createdAt,
      isPoll,
      const DeepCollectionEquality().hash(_pollOptions),
      const DeepCollectionEquality().hash(_pollVoteCounts));

  @override
  String toString() {
    return 'PostModel(uid: $uid, id: $id, gifUrl: $gifUrl, imageString: $imageString, title: $title, body: $body, tags: $tags, likes: $likes, dislikes: $dislikes, commentCount: $commentCount, createdAt: $createdAt, isPoll: $isPoll, pollOptions: $pollOptions, pollVoteCounts: $pollVoteCounts)';
  }
}

/// @nodoc
abstract mixin class _$PostModelCopyWith<$Res>
    implements $PostModelCopyWith<$Res> {
  factory _$PostModelCopyWith(
          _PostModel value, $Res Function(_PostModel) _then) =
      __$PostModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String uid,
      String id,
      String? gifUrl,
      String? imageString,
      List<String>? title,
      List<String>? body,
      List<String> tags,
      int likes,
      int dislikes,
      int commentCount,
      String createdAt,
      bool isPoll,
      List<String>? pollOptions,
      Map<String, int>? pollVoteCounts});
}

/// @nodoc
class __$PostModelCopyWithImpl<$Res> implements _$PostModelCopyWith<$Res> {
  __$PostModelCopyWithImpl(this._self, this._then);

  final _PostModel _self;
  final $Res Function(_PostModel) _then;

  /// Create a copy of PostModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? uid = null,
    Object? id = null,
    Object? gifUrl = freezed,
    Object? imageString = freezed,
    Object? title = freezed,
    Object? body = freezed,
    Object? tags = null,
    Object? likes = null,
    Object? dislikes = null,
    Object? commentCount = null,
    Object? createdAt = null,
    Object? isPoll = null,
    Object? pollOptions = freezed,
    Object? pollVoteCounts = freezed,
  }) {
    return _then(_PostModel(
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      gifUrl: freezed == gifUrl
          ? _self.gifUrl
          : gifUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageString: freezed == imageString
          ? _self.imageString
          : imageString // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _self._title
          : title // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      body: freezed == body
          ? _self._body
          : body // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      likes: null == likes
          ? _self.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as int,
      dislikes: null == dislikes
          ? _self.dislikes
          : dislikes // ignore: cast_nullable_to_non_nullable
              as int,
      commentCount: null == commentCount
          ? _self.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      isPoll: null == isPoll
          ? _self.isPoll
          : isPoll // ignore: cast_nullable_to_non_nullable
              as bool,
      pollOptions: freezed == pollOptions
          ? _self._pollOptions
          : pollOptions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      pollVoteCounts: freezed == pollVoteCounts
          ? _self._pollVoteCounts
          : pollVoteCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
    ));
  }
}

// dart format on
