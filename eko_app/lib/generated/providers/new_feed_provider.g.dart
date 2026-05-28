// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/new_feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NewFeed)
final newFeedProvider = NewFeedProvider._();

final class NewFeedProvider extends $NotifierProvider<
    NewFeed,
    (
      List<int>,
      bool,
    )> {
  NewFeedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'newFeedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$newFeedHash();

  @$internal
  @override
  NewFeed create() => NewFeed();

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

String _$newFeedHash() => r'a05f070cf22738195df8c80c7cdc5a18636be2d7';

abstract class _$NewFeed extends $Notifier<
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
