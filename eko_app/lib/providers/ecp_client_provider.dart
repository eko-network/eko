import 'package:ecp/ecp.dart';
import 'package:eko_app/providers/ecp_client_holder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../generated/providers/ecp_client_provider.g.dart';

@Riverpod(keepAlive: true)
EcpClient ecpClient(Ref ref) {
  final holder = ref.watch(ecpClientHolderProvider);
  if (holder.isLoading || holder.hasError) {
    throw StateError('EcpClient not ready');
  }
  final client = ref.read(ecpClientHolderProvider.notifier).client;
  if (client == null) {
    throw StateError('EcpClient unavailable: sign in and register device');
  }
  return client;
}

@Riverpod(keepAlive: true)
bool ecpMessengerReady(Ref ref) {
  final holder = ref.watch(ecpClientHolderProvider);
  return holder.valueOrNull != null;
}
