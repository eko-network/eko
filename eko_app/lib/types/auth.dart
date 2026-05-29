import 'package:freezed_annotation/freezed_annotation.dart';
part '../generated/types/auth.freezed.dart';

@freezed
abstract class AuthModel with _$AuthModel {
  const factory AuthModel({String? did, String? uid, String? email}) =
      _AuthModel;
  factory AuthModel.loading() => const AuthModel(uid: null);

  factory AuthModel.signedOut() => const AuthModel(uid: null);
}
