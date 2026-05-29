// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/ecp_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(asyncEcpClient)
final asyncEcpClientProvider = AsyncEcpClientProvider._();

final class AsyncEcpClientProvider extends $FunctionalProvider<
        AsyncValue<EcpClient>, EcpClient, FutureOr<EcpClient>>
    with $FutureModifier<EcpClient>, $FutureProvider<EcpClient> {
  AsyncEcpClientProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'asyncEcpClientProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$asyncEcpClientHash();

  @$internal
  @override
  $FutureProviderElement<EcpClient> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<EcpClient> create(Ref ref) {
    return asyncEcpClient(ref);
  }
}

String _$asyncEcpClientHash() => r'71b6188865c317ae670b36ae48c00bc526d59dfa';

@ProviderFor(ecpClient)
final ecpClientProvider = EcpClientProvider._();

final class EcpClientProvider
    extends $FunctionalProvider<EcpClient, EcpClient, EcpClient>
    with $Provider<EcpClient> {
  EcpClientProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'ecpClientProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$ecpClientHash();

  @$internal
  @override
  $ProviderElement<EcpClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EcpClient create(Ref ref) {
    return ecpClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EcpClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EcpClient>(value),
    );
  }
}

String _$ecpClientHash() => r'0a121ddf3721a3bd707a168dfde380d995742f19';
