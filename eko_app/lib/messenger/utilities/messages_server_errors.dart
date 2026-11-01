import 'dart:async';
import 'dart:io';

import 'package:ecp/ecp.dart';
import 'package:http/http.dart' as http;

bool isMessagesServerUnavailable(Object error) {
  if (error is EcpCapabilitiesException) return true;
  if (error is EcpNetworkException) return true;
  if (error is SocketException) return true;
  if (error is http.ClientException) return true;
  if (error is TimeoutException) return true;

  if (error is EcpException && error.cause != null) {
    return isMessagesServerUnavailable(error.cause!);
  }

  return false;
}
