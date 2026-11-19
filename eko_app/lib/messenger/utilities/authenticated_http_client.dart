import 'dart:async';

import 'package:http/http.dart' as http;

const messagesServerTimeout = Duration(seconds: 10);

class AuthenticatedClient extends http.BaseClient {
  final FutureOr<String?> Function() _getToken;
  final http.Client _inner;

  /// Called when the messenger server says this device was removed from the
  /// user's account, which its token doesn't show until it expires.
  final void Function()? onDeviceRemoved;

  AuthenticatedClient(this._getToken, {this.onDeviceRemoved})
    : _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    final response = await _inner.send(request).timeout(messagesServerTimeout);
    if (response.statusCode == 410) onDeviceRemoved?.call();
    return response;
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
