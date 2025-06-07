// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/comment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$commentHash() => r'fd0d87b04f69566904e24d672a99d1e24ee4181c';

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

abstract class _$Comment
    extends BuildlessAutoDisposeAsyncNotifier<CommentModel> {
  late final String id;

  FutureOr<CommentModel> build(
    String id,
  );
}

/// See also [Comment].
@ProviderFor(Comment)
const commentProvider = CommentFamily();

/// See also [Comment].
class CommentFamily extends Family<AsyncValue<CommentModel>> {
  /// See also [Comment].
  const CommentFamily();

  /// See also [Comment].
  CommentProvider call(
    String id,
  ) {
    return CommentProvider(
      id,
    );
  }

  @override
  CommentProvider getProviderOverride(
    covariant CommentProvider provider,
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
  String? get name => r'commentProvider';
}

/// See also [Comment].
class CommentProvider
    extends AutoDisposeAsyncNotifierProviderImpl<Comment, CommentModel> {
  /// See also [Comment].
  CommentProvider(
    String id,
  ) : this._internal(
          () => Comment()..id = id,
          from: commentProvider,
          name: r'commentProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$commentHash,
          dependencies: CommentFamily._dependencies,
          allTransitiveDependencies: CommentFamily._allTransitiveDependencies,
          id: id,
        );

  CommentProvider._internal(
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
  FutureOr<CommentModel> runNotifierBuild(
    covariant Comment notifier,
  ) {
    return notifier.build(
      id,
    );
  }

  @override
  Override overrideWith(Comment Function() create) {
    return ProviderOverride(
      origin: this,
      override: CommentProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<Comment, CommentModel>
      createElement() {
    return _CommentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommentProvider && other.id == id;
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
mixin CommentRef on AutoDisposeAsyncNotifierProviderRef<CommentModel> {
  /// The parameter `id` of this provider.
  String get id;
}

class _CommentProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<Comment, CommentModel>
    with CommentRef {
  _CommentProviderElement(super.provider);

  @override
  String get id => (origin as CommentProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
