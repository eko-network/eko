import 'dart:convert';

Map<String, dynamic>? decodeJwtPayload(String accessToken) {
  try {
    final parts = accessToken.split('.');
    if (parts.length != 3) return null;
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    return jsonDecode(payload) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}
