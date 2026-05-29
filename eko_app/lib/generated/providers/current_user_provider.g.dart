// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/current_user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentUser)
final currentUserProvider = CurrentUserProvider._();

final class CurrentUserProvider
    extends $NotifierProvider<CurrentUser, CurrentUserModel> {
  CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  CurrentUser create() => CurrentUser();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CurrentUserModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CurrentUserModel>(value),
    );
  }
}

String _$currentUserHash() => r'd7f959a2fe90b803483f7a9c867793a63d1daee8';

abstract class _$CurrentUser extends $Notifier<CurrentUserModel> {
  CurrentUserModel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CurrentUserModel, CurrentUserModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CurrentUserModel, CurrentUserModel>,
              CurrentUserModel,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
