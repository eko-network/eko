import 'package:freezed_annotation/freezed_annotation.dart';
part '../generated/types/auth.freezed.dart';

@freezed
abstract class AuthModel with _$AuthModel {
  const factory AuthModel({
    String? uid,
    String? email,
    required bool isLoading,
  }) = _AuthModel;
  factory AuthModel.loading() => const AuthModel(
        uid: null,
        email: null,
        isLoading: true,
      );

  factory AuthModel.signedOut() => const AuthModel(
        uid: null,
        email: null,
        isLoading: false,
      );
}
