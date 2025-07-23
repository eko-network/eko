// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/follow_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$followInfoHash() => r'a41d1261e10f3eea530b0f22ee24eba0f8c40bf4';

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

abstract class _$FollowInfo
    extends BuildlessAutoDisposeAsyncNotifier<FollowInfoModel> {
  late final String uid;

  FutureOr<FollowInfoModel> build(
    String uid,
  );
}

/// See also [FollowInfo].
@ProviderFor(FollowInfo)
const followInfoProvider = FollowInfoFamily();

/// See also [FollowInfo].
class FollowInfoFamily extends Family<AsyncValue<FollowInfoModel>> {
  /// See also [FollowInfo].
  const FollowInfoFamily();

  /// See also [FollowInfo].
  FollowInfoProvider call(
    String uid,
  ) {
    return FollowInfoProvider(
      uid,
    );
  }

  @override
  FollowInfoProvider getProviderOverride(
    covariant FollowInfoProvider provider,
  ) {
    return call(
      provider.uid,
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
  String? get name => r'followInfoProvider';
}

/// See also [FollowInfo].
class FollowInfoProvider
    extends AutoDisposeAsyncNotifierProviderImpl<FollowInfo, FollowInfoModel> {
  /// See also [FollowInfo].
  FollowInfoProvider(
    String uid,
  ) : this._internal(
          () => FollowInfo()..uid = uid,
          from: followInfoProvider,
          name: r'followInfoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$followInfoHash,
          dependencies: FollowInfoFamily._dependencies,
          allTransitiveDependencies:
              FollowInfoFamily._allTransitiveDependencies,
          uid: uid,
        );

  FollowInfoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uid,
  }) : super.internal();

  final String uid;

  @override
  FutureOr<FollowInfoModel> runNotifierBuild(
    covariant FollowInfo notifier,
  ) {
    return notifier.build(
      uid,
    );
  }

  @override
  Override overrideWith(FollowInfo Function() create) {
    return ProviderOverride(
      origin: this,
      override: FollowInfoProvider._internal(
        () => create()..uid = uid,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uid: uid,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<FollowInfo, FollowInfoModel>
      createElement() {
    return _FollowInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FollowInfoProvider && other.uid == uid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FollowInfoRef on AutoDisposeAsyncNotifierProviderRef<FollowInfoModel> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _FollowInfoProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<FollowInfo, FollowInfoModel>
    with FollowInfoRef {
  _FollowInfoProviderElement(super.provider);

  @override
  String get uid => (origin as FollowInfoProvider).uid;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
