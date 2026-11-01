// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/follow_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FollowInfo)
final followInfoProvider = FollowInfoFamily._();

final class FollowInfoProvider
    extends $AsyncNotifierProvider<FollowInfo, FollowInfoModel> {
  FollowInfoProvider._({
    required FollowInfoFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'followInfoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$followInfoHash();

  @override
  String toString() {
    return r'followInfoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FollowInfo create() => FollowInfo();

  @override
  bool operator ==(Object other) {
    return other is FollowInfoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followInfoHash() => r'daebf50cab48f38be3b84b411a2daeae1a9c91b1';

final class FollowInfoFamily extends $Family
    with
        $ClassFamilyOverride<
          FollowInfo,
          AsyncValue<FollowInfoModel>,
          FollowInfoModel,
          FutureOr<FollowInfoModel>,
          String
        > {
  FollowInfoFamily._()
    : super(
        retry: null,
        name: r'followInfoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FollowInfoProvider call(String uid) =>
      FollowInfoProvider._(argument: uid, from: this);

  @override
  String toString() => r'followInfoProvider';
}

abstract class _$FollowInfo extends $AsyncNotifier<FollowInfoModel> {
  late final _$args = ref.$arg as String;
  String get uid => _$args;

  FutureOr<FollowInfoModel> build(String uid);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<FollowInfoModel>, FollowInfoModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FollowInfoModel>, FollowInfoModel>,
              AsyncValue<FollowInfoModel>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
