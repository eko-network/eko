// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../messenger/providers/group_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(group)
final groupProvider = GroupProvider._();

final class GroupProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GroupWithUsers>>,
          List<GroupWithUsers>,
          Stream<List<GroupWithUsers>>
        >
    with
        $FutureModifier<List<GroupWithUsers>>,
        $StreamProvider<List<GroupWithUsers>> {
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
  $StreamProviderElement<List<GroupWithUsers>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GroupWithUsers>> create(Ref ref) {
    return group(ref);
  }
}

String _$groupHash() => r'8a4351d990d525d6922dbd6ce9456ec929372df3';
