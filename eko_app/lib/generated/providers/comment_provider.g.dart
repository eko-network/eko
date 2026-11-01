// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/comment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Comment)
final commentProvider = CommentFamily._();

final class CommentProvider
    extends $AsyncNotifierProvider<Comment, CommentModel> {
  CommentProvider._({
    required CommentFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'commentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$commentHash();

  @override
  String toString() {
    return r'commentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Comment create() => Comment();

  @override
  bool operator ==(Object other) {
    return other is CommentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$commentHash() => r'a3a8c9977cde5910e25dd643ec510dbfae616163';

final class CommentFamily extends $Family
    with
        $ClassFamilyOverride<
          Comment,
          AsyncValue<CommentModel>,
          CommentModel,
          FutureOr<CommentModel>,
          int
        > {
  CommentFamily._()
    : super(
        retry: null,
        name: r'commentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CommentProvider call(int id) => CommentProvider._(argument: id, from: this);

  @override
  String toString() => r'commentProvider';
}

abstract class _$Comment extends $AsyncNotifier<CommentModel> {
  late final _$args = ref.$arg as int;
  int get id => _$args;

  FutureOr<CommentModel> build(int id);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CommentModel>, CommentModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CommentModel>, CommentModel>,
              AsyncValue<CommentModel>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
