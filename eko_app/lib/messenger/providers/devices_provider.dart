import 'dart:typed_data';

import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../generated/messenger/providers/devices_provider.g.dart';

class MessengerDevice {
  final String id;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final Uint8List signerPublicKey;

  const MessengerDevice({
    required this.id,
    required this.createdAt,
    required this.approvedAt,
    required this.signerPublicKey,
  });

  bool get isApproved => approvedAt != null;

  factory MessengerDevice.fromRow(Map<String, dynamic> row) {
    return MessengerDevice(
      id: row['id'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      approvedAt: row['approved_at'] == null
          ? null
          : DateTime.parse(row['approved_at'] as String),
      signerPublicKey: _decodeBytea(row['signer_public_key'] as String),
    );
  }
}

/// PostgREST returns bytea columns as `\x`-prefixed hex.
Uint8List _decodeBytea(String value) {
  final hex = value.startsWith(r'\x') ? value.substring(2) : value;
  final bytes = Uint8List(hex.length ~/ 2);
  for (var i = 0; i < bytes.length; i++) {
    bytes[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return bytes;
}

/// The current user's messenger devices, oldest first. Row level security
/// limits the select to the caller's own devices.
@riverpod
Future<List<MessengerDevice>> messengerDevices(Ref ref) async {
  final rows = await supabase
      .from('devices')
      .select('id, created_at, approved_at, signer_public_key')
      .order('created_at');
  return rows.map(MessengerDevice.fromRow).toList();
}
