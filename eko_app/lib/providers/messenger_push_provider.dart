import 'package:eko_app/providers/messages_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../generated/providers/messenger_push_provider.g.dart';

@Riverpod(keepAlive: true)
void messengerPush(Ref ref) {
  ref.watch(messagePollingProvider);
}
