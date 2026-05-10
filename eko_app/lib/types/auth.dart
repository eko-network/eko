import 'package:freezed_annotation/freezed_annotation.dart';
part '../generated/types/auth.freezed.dart';

@freezed
abstract class AuthModel with _$AuthModel {
  const factory AuthModel({
    String? did,
    String? uid,
    String? email,
    required bool isLoading,
    bool? emailVerified,
    DateTime? creationTime,
    @Default(false) bool pendingPasswordRecovery,
  }) = _AuthModel;
  factory AuthModel.loading() => const AuthModel(
        uid: null,
        email: null,
        isLoading: true,
        emailVerified: null,
        creationTime: null,
        pendingPasswordRecovery: false,
      );

  factory AuthModel.signedOut() => const AuthModel(
        uid: null,
        email: null,
        isLoading: false,
        emailVerified: null,
        creationTime: null,
        pendingPasswordRecovery: false,
      );
}
