// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../messenger/providers/devices_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The current user's messenger devices, oldest first. Row level security
/// limits the select to the caller's own devices.

@ProviderFor(messengerDevices)
final messengerDevicesProvider = MessengerDevicesProvider._();

/// The current user's messenger devices, oldest first. Row level security
/// limits the select to the caller's own devices.

final class MessengerDevicesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MessengerDevice>>,
          List<MessengerDevice>,
          FutureOr<List<MessengerDevice>>
        >
    with
        $FutureModifier<List<MessengerDevice>>,
        $FutureProvider<List<MessengerDevice>> {
  /// The current user's messenger devices, oldest first. Row level security
  /// limits the select to the caller's own devices.
  MessengerDevicesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'messengerDevicesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$messengerDevicesHash();

  @$internal
  @override
  $FutureProviderElement<List<MessengerDevice>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MessengerDevice>> create(Ref ref) {
    return messengerDevices(ref);
  }
}

String _$messengerDevicesHash() => r'0218cea79a934aa1410d1f1facfe5695df3d766e';
