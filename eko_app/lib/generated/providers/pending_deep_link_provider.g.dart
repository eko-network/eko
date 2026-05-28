// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/pending_deep_link_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PendingDeepLink)
final pendingDeepLinkProvider = PendingDeepLinkProvider._();

final class PendingDeepLinkProvider
    extends $NotifierProvider<PendingDeepLink, String?> {
  PendingDeepLinkProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pendingDeepLinkProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pendingDeepLinkHash();

  @$internal
  @override
  PendingDeepLink create() => PendingDeepLink();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$pendingDeepLinkHash() => r'df0029049f266f65ccbc9b426a13d498558e8c21';

abstract class _$PendingDeepLink extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String?, String?>, String?, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
