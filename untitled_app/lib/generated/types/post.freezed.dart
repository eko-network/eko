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
mixin _$PostModel implements DiagnosticableTreeMixin {
  @JsonKey(name: 'author_uid', includeToJson: false)
  String get uid;
  int get id;
  @JsonKey(name: 'gif')
  String? get gifUrl;
  @JsonKey(
      name: 'image',
      fromJson: _asciiImageFromString,
      toJson: _asciiImageToString)
  AsciiImage? get image;
  @JsonKey(fromJson: parseTextToTags, toJson: _joinList)
  List<String> get title;
  @JsonKey(fromJson: parseTextToTags, toJson: _joinList)
  List<String> get body;
  @JsonKey(name: 'like_count', includeToJson: false)
  int get likes;
  @JsonKey(name: 'dislike_count', includeToJson: false)
  int get dislikes;
  @JsonKey(name: 'comment_count', includeToJson: false)
  int get commentCount;
  @JsonKey(name: 'created_at', includeToJson: false)
  String get createdAt;
  List<String>? get pollOptions;
  Map<String, int>? get pollVoteCounts;
  @JsonKey(name: 'ekoed_id')
  int? get ekoedId;
  @JsonKey(name: 'is_eko')
  bool get isEko;
  @LikeStateConverter()
  LikeState get likeState;
  @JsonKey(name: 'chamber_id')
  int? get chamberId;

  /// Create a copy of PostModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PostModelCopyWith<PostModel> get copyWith =>
      _$PostModelCopyWithImpl<PostModel>(this as PostModel, _$identity);

  /// Serializes this PostModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'PostModel'))
      ..add(DiagnosticsProperty('uid', uid))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('gifUrl', gifUrl))
      ..add(DiagnosticsProperty('image', image))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('body', body))
      ..add(DiagnosticsProperty('likes', likes))
      ..add(DiagnosticsProperty('dislikes', dislikes))
      ..add(DiagnosticsProperty('commentCount', commentCount))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('pollOptions', pollOptions))
      ..add(DiagnosticsProperty('pollVoteCounts', pollVoteCounts))
      ..add(DiagnosticsProperty('ekoedId', ekoedId))
      ..add(DiagnosticsProperty('isEko', isEko))
      ..add(DiagnosticsProperty('likeState', likeState))
      ..add(DiagnosticsProperty('chamberId', chamberId));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PostModel &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gifUrl, gifUrl) || other.gifUrl == gifUrl) &&
            (identical(other.image, image) || other.image == image) &&
            const DeepCollectionEquality().equals(other.title, title) &&
            const DeepCollectionEquality().equals(other.body, body) &&
            (identical(other.likes, likes) || other.likes == likes) &&
            (identical(other.dislikes, dislikes) ||
                other.dislikes == dislikes) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality()
                .equals(other.pollOptions, pollOptions) &&
            const DeepCollectionEquality()
                .equals(other.pollVoteCounts, pollVoteCounts) &&
            (identical(other.ekoedId, ekoedId) || other.ekoedId == ekoedId) &&
            (identical(other.isEko, isEko) || other.isEko == isEko) &&
            (identical(other.likeState, likeState) ||
                other.likeState == likeState) &&
            (identical(other.chamberId, chamberId) ||
                other.chamberId == chamberId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uid,
      id,
      gifUrl,
      image,
      const DeepCollectionEquality().hash(title),
      const DeepCollectionEquality().hash(body),
      likes,
      dislikes,
      commentCount,
      createdAt,
      const DeepCollectionEquality().hash(pollOptions),
      const DeepCollectionEquality().hash(pollVoteCounts),
      ekoedId,
      isEko,
      likeState,
      chamberId);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PostModel(uid: $uid, id: $id, gifUrl: $gifUrl, image: $image, title: $title, body: $body, likes: $likes, dislikes: $dislikes, commentCount: $commentCount, createdAt: $createdAt, pollOptions: $pollOptions, pollVoteCounts: $pollVoteCounts, ekoedId: $ekoedId, isEko: $isEko, likeState: $likeState, chamberId: $chamberId)';
  }
}

/// @nodoc
abstract mixin class $PostModelCopyWith<$Res> {
  factory $PostModelCopyWith(PostModel value, $Res Function(PostModel) _then) =
      _$PostModelCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'author_uid', includeToJson: false) String uid,
      int id,
      @JsonKey(name: 'gif') String? gifUrl,
      @JsonKey(
          name: 'image',
          fromJson: _asciiImageFromString,
          toJson: _asciiImageToString)
      AsciiImage? image,
      @JsonKey(fromJson: parseTextToTags, toJson: _joinList) List<String> title,
      @JsonKey(fromJson: parseTextToTags, toJson: _joinList) List<String> body,
      @JsonKey(name: 'like_count', includeToJson: false) int likes,
      @JsonKey(name: 'dislike_count', includeToJson: false) int dislikes,
      @JsonKey(name: 'comment_count', includeToJson: false) int commentCount,
      @JsonKey(name: 'created_at', includeToJson: false) String createdAt,
      List<String>? pollOptions,
      Map<String, int>? pollVoteCounts,
      @JsonKey(name: 'ekoed_id') int? ekoedId,
      @JsonKey(name: 'is_eko') bool isEko,
      @LikeStateConverter() LikeState likeState,
      @JsonKey(name: 'chamber_id') int? chamberId});
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
    Object? image = freezed,
    Object? title = null,
    Object? body = null,
    Object? likes = null,
    Object? dislikes = null,
    Object? commentCount = null,
    Object? createdAt = null,
    Object? pollOptions = freezed,
    Object? pollVoteCounts = freezed,
    Object? ekoedId = freezed,
    Object? isEko = null,
    Object? likeState = null,
    Object? chamberId = freezed,
  }) {
    return _then(_self.copyWith(
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      gifUrl: freezed == gifUrl
          ? _self.gifUrl
          : gifUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _self.image
          : image // ignore: cast_nullable_to_non_nullable
              as AsciiImage?,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as List<String>,
      body: null == body
          ? _self.body
          : body // ignore: cast_nullable_to_non_nullable
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
      pollOptions: freezed == pollOptions
          ? _self.pollOptions
          : pollOptions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      pollVoteCounts: freezed == pollVoteCounts
          ? _self.pollVoteCounts
          : pollVoteCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      ekoedId: freezed == ekoedId
          ? _self.ekoedId
          : ekoedId // ignore: cast_nullable_to_non_nullable
              as int?,
      isEko: null == isEko
          ? _self.isEko
          : isEko // ignore: cast_nullable_to_non_nullable
              as bool,
      likeState: null == likeState
          ? _self.likeState
          : likeState // ignore: cast_nullable_to_non_nullable
              as LikeState,
      chamberId: freezed == chamberId
          ? _self.chamberId
          : chamberId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _PostModel extends PostModel with DiagnosticableTreeMixin {
  const _PostModel(
      {@JsonKey(name: 'author_uid', includeToJson: false) required this.uid,
      required this.id,
      @JsonKey(name: 'gif') this.gifUrl,
      @JsonKey(
          name: 'image',
          fromJson: _asciiImageFromString,
          toJson: _asciiImageToString)
      this.image,
      @JsonKey(fromJson: parseTextToTags, toJson: _joinList)
      final List<String> title = const <String>[],
      @JsonKey(fromJson: parseTextToTags, toJson: _joinList)
      final List<String> body = const <String>[],
      @JsonKey(name: 'like_count', includeToJson: false) this.likes = 0,
      @JsonKey(name: 'dislike_count', includeToJson: false) this.dislikes = 0,
      @JsonKey(name: 'comment_count', includeToJson: false)
      this.commentCount = 0,
      @JsonKey(name: 'created_at', includeToJson: false)
      required this.createdAt,
      final List<String>? pollOptions,
      final Map<String, int>? pollVoteCounts,
      @JsonKey(name: 'ekoed_id') this.ekoedId,
      @JsonKey(name: 'is_eko') this.isEko = false,
      @LikeStateConverter() this.likeState = LikeState.none,
      @JsonKey(name: 'chamber_id') this.chamberId})
      : _title = title,
        _body = body,
        _pollOptions = pollOptions,
        _pollVoteCounts = pollVoteCounts,
        super._();
  factory _PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  @override
  @JsonKey(name: 'author_uid', includeToJson: false)
  final String uid;
  @override
  final int id;
  @override
  @JsonKey(name: 'gif')
  final String? gifUrl;
  @override
  @JsonKey(
      name: 'image',
      fromJson: _asciiImageFromString,
      toJson: _asciiImageToString)
  final AsciiImage? image;
  final List<String> _title;
  @override
  @JsonKey(fromJson: parseTextToTags, toJson: _joinList)
  List<String> get title {
    if (_title is EqualUnmodifiableListView) return _title;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_title);
  }

  final List<String> _body;
  @override
  @JsonKey(fromJson: parseTextToTags, toJson: _joinList)
  List<String> get body {
    if (_body is EqualUnmodifiableListView) return _body;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_body);
  }

  @override
  @JsonKey(name: 'like_count', includeToJson: false)
  final int likes;
  @override
  @JsonKey(name: 'dislike_count', includeToJson: false)
  final int dislikes;
  @override
  @JsonKey(name: 'comment_count', includeToJson: false)
  final int commentCount;
  @override
  @JsonKey(name: 'created_at', includeToJson: false)
  final String createdAt;
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

  @override
  @JsonKey(name: 'ekoed_id')
  final int? ekoedId;
  @override
  @JsonKey(name: 'is_eko')
  final bool isEko;
  @override
  @JsonKey()
  @LikeStateConverter()
  final LikeState likeState;
  @override
  @JsonKey(name: 'chamber_id')
  final int? chamberId;

  /// Create a copy of PostModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PostModelCopyWith<_PostModel> get copyWith =>
      __$PostModelCopyWithImpl<_PostModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PostModelToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'PostModel'))
      ..add(DiagnosticsProperty('uid', uid))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('gifUrl', gifUrl))
      ..add(DiagnosticsProperty('image', image))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('body', body))
      ..add(DiagnosticsProperty('likes', likes))
      ..add(DiagnosticsProperty('dislikes', dislikes))
      ..add(DiagnosticsProperty('commentCount', commentCount))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('pollOptions', pollOptions))
      ..add(DiagnosticsProperty('pollVoteCounts', pollVoteCounts))
      ..add(DiagnosticsProperty('ekoedId', ekoedId))
      ..add(DiagnosticsProperty('isEko', isEko))
      ..add(DiagnosticsProperty('likeState', likeState))
      ..add(DiagnosticsProperty('chamberId', chamberId));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PostModel &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gifUrl, gifUrl) || other.gifUrl == gifUrl) &&
            (identical(other.image, image) || other.image == image) &&
            const DeepCollectionEquality().equals(other._title, _title) &&
            const DeepCollectionEquality().equals(other._body, _body) &&
            (identical(other.likes, likes) || other.likes == likes) &&
            (identical(other.dislikes, dislikes) ||
                other.dislikes == dislikes) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality()
                .equals(other._pollOptions, _pollOptions) &&
            const DeepCollectionEquality()
                .equals(other._pollVoteCounts, _pollVoteCounts) &&
            (identical(other.ekoedId, ekoedId) || other.ekoedId == ekoedId) &&
            (identical(other.isEko, isEko) || other.isEko == isEko) &&
            (identical(other.likeState, likeState) ||
                other.likeState == likeState) &&
            (identical(other.chamberId, chamberId) ||
                other.chamberId == chamberId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uid,
      id,
      gifUrl,
      image,
      const DeepCollectionEquality().hash(_title),
      const DeepCollectionEquality().hash(_body),
      likes,
      dislikes,
      commentCount,
      createdAt,
      const DeepCollectionEquality().hash(_pollOptions),
      const DeepCollectionEquality().hash(_pollVoteCounts),
      ekoedId,
      isEko,
      likeState,
      chamberId);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PostModel(uid: $uid, id: $id, gifUrl: $gifUrl, image: $image, title: $title, body: $body, likes: $likes, dislikes: $dislikes, commentCount: $commentCount, createdAt: $createdAt, pollOptions: $pollOptions, pollVoteCounts: $pollVoteCounts, ekoedId: $ekoedId, isEko: $isEko, likeState: $likeState, chamberId: $chamberId)';
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
      {@JsonKey(name: 'author_uid', includeToJson: false) String uid,
      int id,
      @JsonKey(name: 'gif') String? gifUrl,
      @JsonKey(
          name: 'image',
          fromJson: _asciiImageFromString,
          toJson: _asciiImageToString)
      AsciiImage? image,
      @JsonKey(fromJson: parseTextToTags, toJson: _joinList) List<String> title,
      @JsonKey(fromJson: parseTextToTags, toJson: _joinList) List<String> body,
      @JsonKey(name: 'like_count', includeToJson: false) int likes,
      @JsonKey(name: 'dislike_count', includeToJson: false) int dislikes,
      @JsonKey(name: 'comment_count', includeToJson: false) int commentCount,
      @JsonKey(name: 'created_at', includeToJson: false) String createdAt,
      List<String>? pollOptions,
      Map<String, int>? pollVoteCounts,
      @JsonKey(name: 'ekoed_id') int? ekoedId,
      @JsonKey(name: 'is_eko') bool isEko,
      @LikeStateConverter() LikeState likeState,
      @JsonKey(name: 'chamber_id') int? chamberId});
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
    Object? image = freezed,
    Object? title = null,
    Object? body = null,
    Object? likes = null,
    Object? dislikes = null,
    Object? commentCount = null,
    Object? createdAt = null,
    Object? pollOptions = freezed,
    Object? pollVoteCounts = freezed,
    Object? ekoedId = freezed,
    Object? isEko = null,
    Object? likeState = null,
    Object? chamberId = freezed,
  }) {
    return _then(_PostModel(
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      gifUrl: freezed == gifUrl
          ? _self.gifUrl
          : gifUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _self.image
          : image // ignore: cast_nullable_to_non_nullable
              as AsciiImage?,
      title: null == title
          ? _self._title
          : title // ignore: cast_nullable_to_non_nullable
              as List<String>,
      body: null == body
          ? _self._body
          : body // ignore: cast_nullable_to_non_nullable
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
      pollOptions: freezed == pollOptions
          ? _self._pollOptions
          : pollOptions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      pollVoteCounts: freezed == pollVoteCounts
          ? _self._pollVoteCounts
          : pollVoteCounts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      ekoedId: freezed == ekoedId
          ? _self.ekoedId
          : ekoedId // ignore: cast_nullable_to_non_nullable
              as int?,
      isEko: null == isEko
          ? _self.isEko
          : isEko // ignore: cast_nullable_to_non_nullable
              as bool,
      likeState: null == likeState
          ? _self.likeState
          : likeState // ignore: cast_nullable_to_non_nullable
              as LikeState,
      chamberId: freezed == chamberId
          ? _self.chamberId
          : chamberId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

// dart format on
