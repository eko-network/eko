// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/following_feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FollowingFeed)
final followingFeedProvider = FollowingFeedProvider._();

final class FollowingFeedProvider
    extends $NotifierProvider<FollowingFeed, (List<int>, bool)> {
  FollowingFeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'followingFeedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$followingFeedHash();

  @$internal
  @override
  FollowingFeed create() => FollowingFeed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue((List<int>, bool) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<(List<int>, bool)>(value),
    );
  }
}

String _$followingFeedHash() => r'62358eefda9d57e522d7e37d82188841f95e83df';

abstract class _$FollowingFeed extends $Notifier<(List<int>, bool)> {
  (List<int>, bool) build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<(List<int>, bool), (List<int>, bool)>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<(List<int>, bool), (List<int>, bool)>,
              (List<int>, bool),
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
