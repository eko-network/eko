import 'package:ecp/ecp.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/ecp_session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../generated/providers/ecp_client_provider.g.dart';

@Riverpod(keepAlive: true)
EcpClient ecpClient(Ref ref) {
  final holder = ref.watch(ecpSessionHolderProvider);
  if (holder.isLoading || holder.hasError) {
    throw StateError('EcpClient not ready');
  }
  final client = ref.read(ecpSessionHolderProvider.notifier).client;
  if (client == null) {
    throw StateError('EcpClient unavailable: no ECP session');
  }
  return client;
}

@Riverpod(keepAlive: true)
bool ecpMessengerReady(Ref ref) {
  final uid = ref.watch(authProvider).uid;
  return uid != null && uid.isNotEmpty;
}
