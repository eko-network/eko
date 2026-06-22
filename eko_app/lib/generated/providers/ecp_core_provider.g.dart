// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/ecp_core_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EcpCoreHolder)
final ecpCoreHolderProvider = EcpCoreHolderProvider._();

final class EcpCoreHolderProvider
    extends $AsyncNotifierProvider<EcpCoreHolder, EcpCore?> {
  EcpCoreHolderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ecpCoreHolderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ecpCoreHolderHash();

  @$internal
  @override
  EcpCoreHolder create() => EcpCoreHolder();
}

String _$ecpCoreHolderHash() => r'42c05471654de0879534d819a4d9de9fe452bc09';

abstract class _$EcpCoreHolder extends $AsyncNotifier<EcpCore?> {
  FutureOr<EcpCore?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<EcpCore?>, EcpCore?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<EcpCore?>, EcpCore?>,
              AsyncValue<EcpCore?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
