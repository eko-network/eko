// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../messenger/providers/time_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentTime)
final currentTimeProvider = CurrentTimeProvider._();

final class CurrentTimeProvider
    extends $NotifierProvider<CurrentTime, DateTime> {
  CurrentTimeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentTimeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentTimeHash();

  @$internal
  @override
  CurrentTime create() => CurrentTime();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$currentTimeHash() => r'4c7e0e9e3fd1fd05a29a01a065aead62e71738f9';

abstract class _$CurrentTime extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
