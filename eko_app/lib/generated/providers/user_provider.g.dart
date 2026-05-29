// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../providers/user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(User)
final userProvider = UserFamily._();

final class UserProvider extends $AsyncNotifierProvider<User, UserModel> {
  UserProvider._(
      {required UserFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'userProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userHash();

  @override
  String toString() {
    return r'userProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  User create() => User();

  @override
  bool operator ==(Object other) {
    return other is UserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userHash() => r'74c1248da382a01c7e72b0ff99b61ea96d67cced';

final class UserFamily extends $Family
    with
        $ClassFamilyOverride<User, AsyncValue<UserModel>, UserModel,
            FutureOr<UserModel>, String> {
  UserFamily._()
      : super(
          retry: null,
          name: r'userProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  UserProvider call(
    String uid,
  ) =>
      UserProvider._(argument: uid, from: this);

  @override
  String toString() => r'userProvider';
}

abstract class _$User extends $AsyncNotifier<UserModel> {
  late final _$args = ref.$arg as String;
  String get uid => _$args;

  FutureOr<UserModel> build(
    String uid,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UserModel>, UserModel>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<UserModel>, UserModel>,
        AsyncValue<UserModel>,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
