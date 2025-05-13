// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/post_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$postHash() => r'e052dd5d979582608b76483f98ed9dcd435f4265';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$Post extends BuildlessAutoDisposeAsyncNotifier<PostModel> {
  late final String id;

  FutureOr<PostModel> build(
    String id,
  );
}

/// See also [Post].
@ProviderFor(Post)
const postProvider = PostFamily();

/// See also [Post].
class PostFamily extends Family<AsyncValue<PostModel>> {
  /// See also [Post].
  const PostFamily();

  /// See also [Post].
  PostProvider call(
    String id,
  ) {
    return PostProvider(
      id,
    );
  }

  @override
  PostProvider getProviderOverride(
    covariant PostProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'postProvider';
}

/// See also [Post].
class PostProvider
    extends AutoDisposeAsyncNotifierProviderImpl<Post, PostModel> {
  /// See also [Post].
  PostProvider(
    String id,
  ) : this._internal(
          () => Post()..id = id,
          from: postProvider,
          name: r'postProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product') ? null : _$postHash,
          dependencies: PostFamily._dependencies,
          allTransitiveDependencies: PostFamily._allTransitiveDependencies,
          id: id,
        );

  PostProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  FutureOr<PostModel> runNotifierBuild(
    covariant Post notifier,
  ) {
    return notifier.build(
      id,
    );
  }

  @override
  Override overrideWith(Post Function() create) {
    return ProviderOverride(
      origin: this,
      override: PostProvider._internal(
        () => create()..id = id,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<Post, PostModel> createElement() {
    return _PostProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PostRef on AutoDisposeAsyncNotifierProviderRef<PostModel> {
  /// The parameter `id` of this provider.
  String get id;
}

class _PostProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<Post, PostModel>
    with PostRef {
  _PostProviderElement(super.provider);

  @override
  String get id => (origin as PostProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
