// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/comment_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$commentListHash() => r'd98475df1411e18859665a362ed8b4779136c922';

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

abstract class _$CommentList
    extends BuildlessAutoDisposeNotifier<(List<int>, bool)> {
  late final int postId;

  (List<int>, bool) build(
    int postId,
  );
}

/// See also [CommentList].
@ProviderFor(CommentList)
const commentListProvider = CommentListFamily();

/// See also [CommentList].
class CommentListFamily extends Family<(List<int>, bool)> {
  /// See also [CommentList].
  const CommentListFamily();

  /// See also [CommentList].
  CommentListProvider call(
    int postId,
  ) {
    return CommentListProvider(
      postId,
    );
  }

  @override
  CommentListProvider getProviderOverride(
    covariant CommentListProvider provider,
  ) {
    return call(
      provider.postId,
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
  String? get name => r'commentListProvider';
}

/// See also [CommentList].
class CommentListProvider
    extends AutoDisposeNotifierProviderImpl<CommentList, (List<int>, bool)> {
  /// See also [CommentList].
  CommentListProvider(
    int postId,
  ) : this._internal(
          () => CommentList()..postId = postId,
          from: commentListProvider,
          name: r'commentListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$commentListHash,
          dependencies: CommentListFamily._dependencies,
          allTransitiveDependencies:
              CommentListFamily._allTransitiveDependencies,
          postId: postId,
        );

  CommentListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postId,
  }) : super.internal();

  final int postId;

  @override
  (List<int>, bool) runNotifierBuild(
    covariant CommentList notifier,
  ) {
    return notifier.build(
      postId,
    );
  }

  @override
  Override overrideWith(CommentList Function() create) {
    return ProviderOverride(
      origin: this,
      override: CommentListProvider._internal(
        () => create()..postId = postId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postId: postId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<CommentList, (List<int>, bool)>
      createElement() {
    return _CommentListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommentListProvider && other.postId == postId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommentListRef on AutoDisposeNotifierProviderRef<(List<int>, bool)> {
  /// The parameter `postId` of this provider.
  int get postId;
}

class _CommentListProviderElement
    extends AutoDisposeNotifierProviderElement<CommentList, (List<int>, bool)>
    with CommentListRef {
  _CommentListProviderElement(super.provider);

  @override
  int get postId => (origin as CommentListProvider).postId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
