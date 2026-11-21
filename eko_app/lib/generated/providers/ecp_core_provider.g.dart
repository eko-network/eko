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

String _$ecpCoreHolderHash() => r'cef9e5943ee1e3dfb4c5b3fc97064f8cea2b985a';

abstract class _$EcpCoreHolder extends $AsyncNotifier<EcpCore?> {
  FutureOr<EcpCore?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<EcpCore?>, EcpCore?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<EcpCore?>, EcpCore?>,
              AsyncValue<EcpCore?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Whether messenger setup should say this device was removed from the
/// user's account, see [EcpCoreHolder.checkDeviceRemoved].

@ProviderFor(DeviceRemovedNotice)
final deviceRemovedNoticeProvider = DeviceRemovedNoticeProvider._();

/// Whether messenger setup should say this device was removed from the
/// user's account, see [EcpCoreHolder.checkDeviceRemoved].
final class DeviceRemovedNoticeProvider
    extends $NotifierProvider<DeviceRemovedNotice, bool> {
  /// Whether messenger setup should say this device was removed from the
  /// user's account, see [EcpCoreHolder.checkDeviceRemoved].
  DeviceRemovedNoticeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceRemovedNoticeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceRemovedNoticeHash();

  @$internal
  @override
  DeviceRemovedNotice create() => DeviceRemovedNotice();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$deviceRemovedNoticeHash() =>
    r'a4fd151442f064c6b6a223967679b722a2ddeaf9';

/// Whether messenger setup should say this device was removed from the
/// user's account, see [EcpCoreHolder.checkDeviceRemoved].

abstract class _$DeviceRemovedNotice extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
