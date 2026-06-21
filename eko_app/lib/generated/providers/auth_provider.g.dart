// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Auth)
final authProvider = AuthProvider._();

final class AuthProvider extends $AsyncNotifierProvider<Auth, AuthModel> {
  AuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authHash();

  @$internal
  @override
  Auth create() => Auth();
}

String _$authHash() => r'74d23c0e27955fd9148ec8bc8c5fb09133fd8b2b';

abstract class _$Auth extends $AsyncNotifier<AuthModel> {
  FutureOr<AuthModel> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthModel>, AuthModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthModel>, AuthModel>,
              AsyncValue<AuthModel>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
