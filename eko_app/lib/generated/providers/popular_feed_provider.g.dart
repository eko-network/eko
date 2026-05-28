// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/popular_feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PopularFeed)
final popularFeedProvider = PopularFeedProvider._();

final class PopularFeedProvider extends $NotifierProvider<
    PopularFeed,
    (
      List<int>,
      bool,
    )> {
  PopularFeedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'popularFeedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$popularFeedHash();

  @$internal
  @override
  PopularFeed create() => PopularFeed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
      (
        List<int>,
        bool,
      ) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<
          (
            List<int>,
            bool,
          )>(value),
    );
  }
}

String _$popularFeedHash() => r'7706d653c1eff0da6b588bd950795944a7557dfd';

abstract class _$PopularFeed extends $Notifier<
    (
      List<int>,
      bool,
    )> {
  (
    List<int>,
    bool,
  ) build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<
        (
          List<int>,
          bool,
        ),
        (
          List<int>,
          bool,
        )>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<
            (
              List<int>,
              bool,
            ),
            (
              List<int>,
              bool,
            )>,
        (
          List<int>,
          bool,
        ),
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
