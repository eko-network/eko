import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdaptiveChat extends ConsumerWidget {
  final int? selectedConversationId;

  const AdaptiveChat({super.key, this.selectedConversationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Center(child: Text('Messaging is disabled')),
    );
  }
}
