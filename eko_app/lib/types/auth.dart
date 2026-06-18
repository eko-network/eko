import 'package:eko_app/types/device.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part '../generated/types/auth.freezed.dart';

@freezed
abstract class AuthModel with _$AuthModel {
  const factory AuthModel({
    required String? uid,
    String? email,
    DeviceModel? device,
  }) = _AuthModel;
  factory AuthModel.signedOut() => AuthModel(uid: null, email: null);
}
