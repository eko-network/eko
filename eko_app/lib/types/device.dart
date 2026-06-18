import 'package:eko_app/utilities/jwt_decode.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
part '../generated/types/device.freezed.dart';

@freezed
abstract class DeviceModel with _$DeviceModel {
  const DeviceModel._();

  const factory DeviceModel({
    required String? did,
    required DateTime? dat,
    @Default(false) bool isRegistering,
  }) = _DeviceModel;

  factory DeviceModel.idle() => const DeviceModel(did: null, dat: null);

  factory DeviceModel.fromSession(Session session) {
    final claims = decodeJwtPayload(session.accessToken);
    final meta = claims?['app_metadata'];
    if (meta is! Map) return DeviceModel.idle();

    final rawDid = meta['did'];
    final did = rawDid is String && rawDid.isNotEmpty ? rawDid : null;
    final rawDat = meta['dat'];
    final dat = rawDat is DateTime
        ? rawDat
        : rawDat is String
        ? DateTime.tryParse(rawDat)
        : null;
    return DeviceModel(did: did, dat: dat);
  }

  bool get isRegistered => did != null && did!.isNotEmpty;
}
