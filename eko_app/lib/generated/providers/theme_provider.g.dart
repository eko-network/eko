// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ColorTheme)
final colorThemeProvider = ColorThemeProvider._();

final class ColorThemeProvider
    extends $NotifierProvider<ColorTheme, ColorScheme> {
  ColorThemeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'colorThemeProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$colorThemeHash();

  @$internal
  @override
  ColorTheme create() => ColorTheme();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ColorScheme value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ColorScheme>(value),
    );
  }
}

String _$colorThemeHash() => r'b55625ceac9a93bcae2722767d2bf9f0dd71210c';

abstract class _$ColorTheme extends $Notifier<ColorScheme> {
  ColorScheme build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ColorScheme, ColorScheme>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ColorScheme, ColorScheme>, ColorScheme, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
