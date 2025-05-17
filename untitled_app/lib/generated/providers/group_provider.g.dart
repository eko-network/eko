// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/group_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupHash() => r'36188cc5607a4c5aaf52225753fa0dc393a68ef4';

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

abstract class _$Group extends BuildlessAutoDisposeAsyncNotifier<GroupModel> {
  late final String id;

  FutureOr<GroupModel> build(
    String id,
  );
}

/// See also [Group].
@ProviderFor(Group)
const groupProvider = GroupFamily();

/// See also [Group].
class GroupFamily extends Family<AsyncValue<GroupModel>> {
  /// See also [Group].
  const GroupFamily();

  /// See also [Group].
  GroupProvider call(
    String id,
  ) {
    return GroupProvider(
      id,
    );
  }

  @override
  GroupProvider getProviderOverride(
    covariant GroupProvider provider,
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
  String? get name => r'groupProvider';
}

/// See also [Group].
class GroupProvider
    extends AutoDisposeAsyncNotifierProviderImpl<Group, GroupModel> {
  /// See also [Group].
  GroupProvider(
    String id,
  ) : this._internal(
          () => Group()..id = id,
          from: groupProvider,
          name: r'groupProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupHash,
          dependencies: GroupFamily._dependencies,
          allTransitiveDependencies: GroupFamily._allTransitiveDependencies,
          id: id,
        );

  GroupProvider._internal(
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
  FutureOr<GroupModel> runNotifierBuild(
    covariant Group notifier,
  ) {
    return notifier.build(
      id,
    );
  }

  @override
  Override overrideWith(Group Function() create) {
    return ProviderOverride(
      origin: this,
      override: GroupProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<Group, GroupModel> createElement() {
    return _GroupProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupProvider && other.id == id;
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
mixin GroupRef on AutoDisposeAsyncNotifierProviderRef<GroupModel> {
  /// The parameter `id` of this provider.
  String get id;
}

class _GroupProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<Group, GroupModel>
    with GroupRef {
  _GroupProviderElement(super.provider);

  @override
  String get id => (origin as GroupProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
