// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../messenger/widgets/group_card.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the group with row id [groupId] is a DM or a note to self, its
/// members other than us, and whose picture it shows.

@ProviderFor(groupMeta)
final groupMetaProvider = GroupMetaFamily._();

/// Whether the group with row id [groupId] is a DM or a note to self, its
/// members other than us, and whose picture it shows.

final class GroupMetaProvider
    extends
        $FunctionalProvider<
          AsyncValue<(bool, bool, Set<String>, String)>,
          (bool, bool, Set<String>, String),
          FutureOr<(bool, bool, Set<String>, String)>
        >
    with
        $FutureModifier<(bool, bool, Set<String>, String)>,
        $FutureProvider<(bool, bool, Set<String>, String)> {
  /// Whether the group with row id [groupId] is a DM or a note to self, its
  /// members other than us, and whose picture it shows.
  GroupMetaProvider._({
    required GroupMetaFamily super.from,
    required int super.argument,
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
  $FutureProviderElement<(bool, bool, Set<String>, String)> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<(bool, bool, Set<String>, String)> create(Ref ref) {
    final argument = this.argument as int;
    return groupMeta(ref, argument);
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

String _$groupMetaHash() => r'23d72fed1256129bdf8ef640d219904d725d9a5c';

/// Whether the group with row id [groupId] is a DM or a note to self, its
/// members other than us, and whose picture it shows.

final class GroupMetaFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<(bool, bool, Set<String>, String)>,
          int
        > {
  GroupMetaFamily._()
    : super(
        retry: null,
        name: r'groupMetaProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the group with row id [groupId] is a DM or a note to self, its
  /// members other than us, and whose picture it shows.

  GroupMetaProvider call(int groupId) =>
      GroupMetaProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupMetaProvider';
}
