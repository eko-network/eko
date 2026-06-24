// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../messenger/providers/approval_stream_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(rawApprovalStream)
final rawApprovalStreamProvider = RawApprovalStreamProvider._();

final class RawApprovalStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<(StoredApprovalRequest, DateTime)?>,
          (StoredApprovalRequest, DateTime)?,
          Stream<(StoredApprovalRequest, DateTime)?>
        >
    with
        $FutureModifier<(StoredApprovalRequest, DateTime)?>,
        $StreamProvider<(StoredApprovalRequest, DateTime)?> {
  RawApprovalStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rawApprovalStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rawApprovalStreamHash();

  @$internal
  @override
  $StreamProviderElement<(StoredApprovalRequest, DateTime)?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<(StoredApprovalRequest, DateTime)?> create(Ref ref) {
    return rawApprovalStream(ref);
  }
}

String _$rawApprovalStreamHash() => r'424438c6bf5cb74474345f419b84c1d3e6fd9473';

@ProviderFor(ValidatedApproval)
final validatedApprovalProvider = ValidatedApprovalProvider._();

final class ValidatedApprovalProvider
    extends $NotifierProvider<ValidatedApproval, StoredApprovalRequest?> {
  ValidatedApprovalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'validatedApprovalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$validatedApprovalHash();

  @$internal
  @override
  ValidatedApproval create() => ValidatedApproval();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoredApprovalRequest? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoredApprovalRequest?>(value),
    );
  }
}

String _$validatedApprovalHash() => r'0862a2f90cdce2274937f34bd85aadcf991e0a12';

abstract class _$ValidatedApproval extends $Notifier<StoredApprovalRequest?> {
  StoredApprovalRequest? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<StoredApprovalRequest?, StoredApprovalRequest?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StoredApprovalRequest?, StoredApprovalRequest?>,
              StoredApprovalRequest?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
