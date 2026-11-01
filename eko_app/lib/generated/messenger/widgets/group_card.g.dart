// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../messenger/widgets/group_card.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(groupMeta)
final groupMetaProvider = GroupMetaFamily._();

final class GroupMetaProvider
    extends
        $FunctionalProvider<
          (bool, bool, Set<String>),
          (bool, bool, Set<String>),
          (bool, bool, Set<String>)
        >
    with $Provider<(bool, bool, Set<String>)> {
  GroupMetaProvider._({
    required GroupMetaFamily super.from,
    required GroupWithUsers super.argument,
  }) : super(
         retry: null,
         name: r'groupMetaProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupMetaHash();

  @override
  String toString() {
    return r'groupMetaProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<(bool, bool, Set<String>)> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  (bool, bool, Set<String>) create(Ref ref) {
    final argument = this.argument as GroupWithUsers;
    return groupMeta(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue((bool, bool, Set<String>) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<(bool, bool, Set<String>)>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GroupMetaProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupMetaHash() => r'c5b7f63fbc20ecff238d4ba25783a4c88ebf68d1';

final class GroupMetaFamily extends $Family
    with $FunctionalFamilyOverride<(bool, bool, Set<String>), GroupWithUsers> {
  GroupMetaFamily._()
    : super(
        retry: null,
        name: r'groupMetaProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GroupMetaProvider call(GroupWithUsers group) =>
      GroupMetaProvider._(argument: group, from: this);

  @override
  String toString() => r'groupMetaProvider';
}
