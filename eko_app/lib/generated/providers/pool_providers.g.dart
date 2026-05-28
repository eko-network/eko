// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/pool_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(postPool)
final postPoolProvider = PostPoolProvider._();

final class PostPoolProvider extends $FunctionalProvider<
    PoolService<PostModel, int>,
    PoolService<PostModel, int>,
    PoolService<PostModel, int>> with $Provider<PoolService<PostModel, int>> {
  PostPoolProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'postPoolProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$postPoolHash();

  @$internal
  @override
  $ProviderElement<PoolService<PostModel, int>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PoolService<PostModel, int> create(Ref ref) {
    return postPool(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PoolService<PostModel, int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PoolService<PostModel, int>>(value),
    );
  }
}

String _$postPoolHash() => r'35cb84d47f9384c68025c43175f13aae86c5c1dc';

@ProviderFor(commentPool)
final commentPoolProvider = CommentPoolProvider._();

final class CommentPoolProvider extends $FunctionalProvider<
        PoolService<CommentModel, int>,
        PoolService<CommentModel, int>,
        PoolService<CommentModel, int>>
    with $Provider<PoolService<CommentModel, int>> {
  CommentPoolProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'commentPoolProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$commentPoolHash();

  @$internal
  @override
  $ProviderElement<PoolService<CommentModel, int>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PoolService<CommentModel, int> create(Ref ref) {
    return commentPool(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PoolService<CommentModel, int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<PoolService<CommentModel, int>>(value),
    );
  }
}

String _$commentPoolHash() => r'6d5db9ac2c00c13a0404ccd280a8eb83ad3da0a0';

@ProviderFor(userPool)
final userPoolProvider = UserPoolProvider._();

final class UserPoolProvider extends $FunctionalProvider<
        PoolService<UserModel, String>,
        PoolService<UserModel, String>,
        PoolService<UserModel, String>>
    with $Provider<PoolService<UserModel, String>> {
  UserPoolProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userPoolProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userPoolHash();

  @$internal
  @override
  $ProviderElement<PoolService<UserModel, String>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PoolService<UserModel, String> create(Ref ref) {
    return userPool(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PoolService<UserModel, String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<PoolService<UserModel, String>>(value),
    );
  }
}

String _$userPoolHash() => r'c433d66c3deaf569fffb2333d96add557966db9f';
