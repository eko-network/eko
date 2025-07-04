// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/presence_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$presenceHash() => r'c48e8aa9832c15b483ffcfebc928f8405cac170d';

/// See also [Presence].
@ProviderFor(Presence)
final presenceProvider =
    AutoDisposeNotifierProvider<Presence, OnlineStatus>.internal(
  Presence.new,
  name: r'presenceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$presenceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Presence = AutoDisposeNotifier<OnlineStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
