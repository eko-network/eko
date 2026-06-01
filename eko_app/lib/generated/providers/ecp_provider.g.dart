// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/ecp_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(asyncEcpClient)
final asyncEcpClientProvider = AsyncEcpClientProvider._();

final class AsyncEcpClientProvider
    extends
        $FunctionalProvider<
          AsyncValue<EcpClient>,
          EcpClient,
          FutureOr<EcpClient>
        >
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

String _$asyncEcpClientHash() => r'35be1c3deed0b89d9476cdee1232eec4a61e9cf3';

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

@ProviderFor(inboxPolling)
final inboxPollingProvider = InboxPollingProvider._();

final class InboxPollingProvider extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  InboxPollingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxPollingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxPollingHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return inboxPolling(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$inboxPollingHash() => r'3193221289f56da9654b9fdaad827925323ee82d';
