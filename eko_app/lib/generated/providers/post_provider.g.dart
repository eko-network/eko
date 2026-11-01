// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/post_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Post)
final postProvider = PostFamily._();

final class PostProvider extends $AsyncNotifierProvider<Post, PostModel> {
  PostProvider._({required PostFamily super.from, required int super.argument})
    : super(
        retry: null,
        name: r'postProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postHash();

  @override
  String toString() {
    return r'postProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Post create() => Post();

  @override
  bool operator ==(Object other) {
    return other is PostProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postHash() => r'308fac0d580b399232c6f5379895669b0ea0d4b1';

final class PostFamily extends $Family
    with
        $ClassFamilyOverride<
          Post,
          AsyncValue<PostModel>,
          PostModel,
          FutureOr<PostModel>,
          int
        > {
  PostFamily._()
    : super(
        retry: null,
        name: r'postProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PostProvider call(int id) => PostProvider._(argument: id, from: this);

  @override
  String toString() => r'postProvider';
}

abstract class _$Post extends $AsyncNotifier<PostModel> {
  late final _$args = ref.$arg as int;
  int get id => _$args;

  FutureOr<PostModel> build(int id);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PostModel>, PostModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PostModel>, PostModel>,
              AsyncValue<PostModel>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
