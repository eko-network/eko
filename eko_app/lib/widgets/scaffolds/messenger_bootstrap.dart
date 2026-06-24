import 'package:eko_app/messenger/providers/approval_stream_provider.dart';
import 'package:eko_app/messenger/views/approval.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/ecp_provider.dart';
import 'package:eko_app/utilities/platform.dart' as platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Starts the messenger WebSocket for registered, approved devices as soon as
/// the user is authenticated — without requiring a visit to `/messages`.
class MessengerBootstrap extends ConsumerWidget {
  const MessengerBootstrap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (platform.isWeb) return child;

    final device = ref.watch(authProvider).value?.device;
    final did = device?.did;
    final dat = device?.dat;
    final ecpInitialized = did != null && did.isNotEmpty && dat != null;

    if (ecpInitialized) {
      ref.watch(inboxPollingProvider);
    }

    return ecpInitialized ? ApprovalRequestHandler(child: child) : child;
  }
}

class ApprovalRequestHandler extends ConsumerWidget {
  final Widget child;
  const ApprovalRequestHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(validatedApprovalProvider);
    if (request == null) {
      return child;
    }
    return ApprovalView(request: request);
  }
}
