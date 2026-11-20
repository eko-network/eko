// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../messenger/providers/group_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The active groups, the one with the newest message first.

@ProviderFor(group)
final groupProvider = GroupProvider._();

/// The active groups, the one with the newest message first.

final class GroupProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MlsGroupRecord>>,
          List<MlsGroupRecord>,
          Stream<List<MlsGroupRecord>>
        >
    with
        $FutureModifier<List<MlsGroupRecord>>,
        $StreamProvider<List<MlsGroupRecord>> {
  /// The active groups, the one with the newest message first.
  GroupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupHash();

  @$internal
  @override
  $StreamProviderElement<List<MlsGroupRecord>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MlsGroupRecord>> create(Ref ref) {
    return group(ref);
  }
}

String _$groupHash() => r'3f0f4bc0a78dbbabf3fb70c00f25d918508fa1f0';

/// The uids of the members of the group with row id [groupId]. Only their
/// devices change after a group is made, not who is in it.

@ProviderFor(groupMembers)
final groupMembersProvider = GroupMembersFamily._();

/// The uids of the members of the group with row id [groupId]. Only their
/// devices change after a group is made, not who is in it.

final class GroupMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// The uids of the members of the group with row id [groupId]. Only their
  /// devices change after a group is made, not who is in it.
  GroupMembersProvider._({
    required GroupMembersFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'groupMembersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupMembersHash();

  @override
  String toString() {
    return r'groupMembersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as int;
    return groupMembers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupMembersHash() => r'4a2af038d5d46ab2458ce3af350046a75fa8bac8';

/// The uids of the members of the group with row id [groupId]. Only their
/// devices change after a group is made, not who is in it.

final class GroupMembersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<String>>, int> {
  GroupMembersFamily._()
    : super(
        retry: null,
        name: r'groupMembersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The uids of the members of the group with row id [groupId]. Only their
  /// devices change after a group is made, not who is in it.

  GroupMembersProvider call(int groupId) =>
      GroupMembersProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupMembersProvider';
}
