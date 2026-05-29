// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/comment_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CommentList)
final commentListProvider = CommentListFamily._();

final class CommentListProvider
    extends $NotifierProvider<CommentList, (List<int>, bool)> {
  CommentListProvider._({
    required CommentListFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'commentListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$commentListHash();

  @override
  String toString() {
    return r'commentListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CommentList create() => CommentList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue((List<int>, bool) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<(List<int>, bool)>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CommentListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$commentListHash() => r'bca825d1244663f507f28c7a977efed927677311';

final class CommentListFamily extends $Family
    with
        $ClassFamilyOverride<
          CommentList,
          (List<int>, bool),
          (List<int>, bool),
          (List<int>, bool),
          int
        > {
  CommentListFamily._()
    : super(
        retry: null,
        name: r'commentListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CommentListProvider call(int postId) =>
      CommentListProvider._(argument: postId, from: this);

  @override
  String toString() => r'commentListProvider';
}

abstract class _$CommentList extends $Notifier<(List<int>, bool)> {
  late final _$args = ref.$arg as int;
  int get postId => _$args;

  (List<int>, bool) build(int postId);
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
    element.handleCreate(ref, () => build(_$args));
  }
}
