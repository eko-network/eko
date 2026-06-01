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
          (bool, bool, List<String>),
          (bool, bool, List<String>),
          (bool, bool, List<String>)
        >
    with $Provider<(bool, bool, List<String>)> {
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
  $ProviderElement<(bool, bool, List<String>)> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  (bool, bool, List<String>) create(Ref ref) {
    final argument = this.argument as GroupWithUsers;
    return groupMeta(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue((bool, bool, List<String>) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<(bool, bool, List<String>)>(value),
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

String _$groupMetaHash() => r'f775e1e6d1dd24740907b826f8e69112ca676e8b';

final class GroupMetaFamily extends $Family
    with $FunctionalFamilyOverride<(bool, bool, List<String>), GroupWithUsers> {
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
