import 'package:ecp/ecp.dart';

class EcpSession {
  final Uri did;
  final String accessToken;
  final String refreshToken;
  final Person actor;
  final DateTime expiresAt;
  final Uri serverUrl;

  const EcpSession({
    required this.did,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.serverUrl,
    required this.actor,
  });

  bool get isExpired {
    return DateTime.now()
        .isAfter(expiresAt.subtract(const Duration(seconds: 30)));
  }
}
