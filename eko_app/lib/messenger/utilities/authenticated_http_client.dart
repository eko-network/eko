import 'package:http/http.dart' as http;

const messagesServerTimeout = Duration(seconds: 10);

class AuthenticatedClient extends http.BaseClient {
  final String? Function() _getToken;
  final http.Client _inner;

  AuthenticatedClient(this._getToken) : _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = _getToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return _inner.send(request).timeout(messagesServerTimeout);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
