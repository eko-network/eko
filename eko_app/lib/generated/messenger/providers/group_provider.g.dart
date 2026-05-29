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
          AsyncValue<List<MlsGroupRecord>>,
          List<MlsGroupRecord>,
          Stream<List<MlsGroupRecord>>
        >
    with
        $FutureModifier<List<MlsGroupRecord>>,
        $StreamProvider<List<MlsGroupRecord>> {
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

String _$groupHash() => r'd30d4d90fedf6f2325e0572565417e9b6555aa97';
