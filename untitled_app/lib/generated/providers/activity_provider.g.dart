// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/activity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activityHash() => r'6f683b7c487d39c6e6ba973424fe82c9b055f3ce';

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

abstract class _$Activity
    extends BuildlessAutoDisposeAsyncNotifier<ActivityModel> {
  late final String id;

  FutureOr<ActivityModel> build(
    String id,
  );
}

/// See also [Activity].
@ProviderFor(Activity)
const activityProvider = ActivityFamily();

/// See also [Activity].
class ActivityFamily extends Family<AsyncValue<ActivityModel>> {
  /// See also [Activity].
  const ActivityFamily();

  /// See also [Activity].
  ActivityProvider call(
    String id,
  ) {
    return ActivityProvider(
      id,
    );
  }

  @override
  ActivityProvider getProviderOverride(
    covariant ActivityProvider provider,
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
  String? get name => r'activityProvider';
}

/// See also [Activity].
class ActivityProvider
    extends AutoDisposeAsyncNotifierProviderImpl<Activity, ActivityModel> {
  /// See also [Activity].
  ActivityProvider(
    String id,
  ) : this._internal(
          () => Activity()..id = id,
          from: activityProvider,
          name: r'activityProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$activityHash,
          dependencies: ActivityFamily._dependencies,
          allTransitiveDependencies: ActivityFamily._allTransitiveDependencies,
          id: id,
        );

  ActivityProvider._internal(
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
  FutureOr<ActivityModel> runNotifierBuild(
    covariant Activity notifier,
  ) {
    return notifier.build(
      id,
    );
  }

  @override
  Override overrideWith(Activity Function() create) {
    return ProviderOverride(
      origin: this,
      override: ActivityProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<Activity, ActivityModel>
      createElement() {
    return _ActivityProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActivityProvider && other.id == id;
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
mixin ActivityRef on AutoDisposeAsyncNotifierProviderRef<ActivityModel> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ActivityProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<Activity, ActivityModel>
    with ActivityRef {
  _ActivityProviderElement(super.provider);

  @override
  String get id => (origin as ActivityProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
