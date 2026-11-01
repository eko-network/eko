// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/nav_bar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NavBar)
final navBarProvider = NavBarProvider._();

final class NavBarProvider extends $NotifierProvider<NavBar, bool> {
  NavBarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navBarProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navBarHash();

  @$internal
  @override
  NavBar create() => NavBar();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$navBarHash() => r'a25d84dda5b03559146c374a6a19f825e291e643';

abstract class _$NavBar extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
