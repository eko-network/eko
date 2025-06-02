// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/online_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onlineHash() => r'560d166cb31c3417aee275d3fff7052af6a6e8e8';

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

abstract class _$Online extends BuildlessAutoDisposeNotifier<OnlineStatus> {
  late final String id;

  OnlineStatus build(
    String id,
  );
}

/// See also [Online].
@ProviderFor(Online)
const onlineProvider = OnlineFamily();

/// See also [Online].
class OnlineFamily extends Family<OnlineStatus> {
  /// See also [Online].
  const OnlineFamily();

  /// See also [Online].
  OnlineProvider call(
    String id,
  ) {
    return OnlineProvider(
      id,
    );
  }

  @override
  OnlineProvider getProviderOverride(
    covariant OnlineProvider provider,
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
  String? get name => r'onlineProvider';
}

/// See also [Online].
class OnlineProvider
    extends AutoDisposeNotifierProviderImpl<Online, OnlineStatus> {
  /// See also [Online].
  OnlineProvider(
    String id,
  ) : this._internal(
          () => Online()..id = id,
          from: onlineProvider,
          name: r'onlineProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$onlineHash,
          dependencies: OnlineFamily._dependencies,
          allTransitiveDependencies: OnlineFamily._allTransitiveDependencies,
          id: id,
        );

  OnlineProvider._internal(
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
  OnlineStatus runNotifierBuild(
    covariant Online notifier,
  ) {
    return notifier.build(
      id,
    );
  }

  @override
  Override overrideWith(Online Function() create) {
    return ProviderOverride(
      origin: this,
      override: OnlineProvider._internal(
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
  AutoDisposeNotifierProviderElement<Online, OnlineStatus> createElement() {
    return _OnlineProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OnlineProvider && other.id == id;
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
mixin OnlineRef on AutoDisposeNotifierProviderRef<OnlineStatus> {
  /// The parameter `id` of this provider.
  String get id;
}

class _OnlineProviderElement
    extends AutoDisposeNotifierProviderElement<Online, OnlineStatus>
    with OnlineRef {
  _OnlineProviderElement(super.provider);

  @override
  String get id => (origin as OnlineProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
