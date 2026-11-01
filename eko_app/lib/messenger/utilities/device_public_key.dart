import 'dart:typed_data';

import 'package:crypto/crypto.dart';

String devicePublicKeyCode(Uint8List signerPublicKey) {
  final digest = sha256.convert(signerPublicKey);
  final value = digest.bytes
      .sublist(0, 4)
      .fold<int>(0, (acc, byte) => (acc << 8) | byte);
  return (value % 1000000).toString().padLeft(6, '0');
}
