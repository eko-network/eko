// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/post_preview_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PostPreview)
final postPreviewProvider = PostPreviewProvider._();

final class PostPreviewProvider extends $NotifierProvider<PostPreview, bool> {
  PostPreviewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postPreviewProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postPreviewHash();

  @$internal
  @override
  PostPreview create() => PostPreview();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$postPreviewHash() => r'97af7488599d078d3d5473cf990a77f88702eef4';

abstract class _$PostPreview extends $Notifier<bool> {
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
