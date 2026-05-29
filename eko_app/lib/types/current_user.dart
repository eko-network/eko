import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:eko_app/types/user.dart';

part '../generated/types/current_user.freezed.dart';

@freezed
abstract class CurrentUserModel with _$CurrentUserModel {
  const factory CurrentUserModel({required UserModel user}) = _CurrentUserModel;
  factory CurrentUserModel.fromJson(Map<String, dynamic> json) {
    return CurrentUserModel(user: UserModel.fromJson(json));
  }
  factory CurrentUserModel.loading() {
    return CurrentUserModel(user: UserModel.userNotFound());
  }
}
