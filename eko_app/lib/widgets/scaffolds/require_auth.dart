import 'package:eko_app/messenger/views/messenger_setup_page.dart';
import 'package:eko_app/providers/ecp_core_provider.dart';
import 'package:eko_app/providers/ecp_provider.dart';
import 'package:eko_app/utilities/platform.dart' as platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/widgets/loading/loading_spinner.dart';

Widget _e(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) context.go('/');
  });
  return const Center(child: LoadingSpinner());
}

class RequireAuth extends ConsumerWidget {
  final Widget child;
  const RequireAuth({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = ref.watch(currentUserProvider);

    if (auth.isLoading) {
      debugPrint('[RequireAuth] authProvider loading');
      return const Center(child: LoadingSpinner());
    }
    if (auth.hasError) {
      debugPrint('[RequireAuth] authProvider error');
      return _e(context);
    }
    if (auth.value?.uid == null) {
      debugPrint('[RequireAuth] authProvider not loading but uid==null');
      return _e(context);
    }
    if (user.user.uid.isEmpty) {
      debugPrint(
        '[RequireAuth] authProvider not loading but user.uid is empty',
      );
      return const Center(child: LoadingSpinner());
    }
    debugPrint('[RequireAuth] authProvider satisfied');
    return child;
  }
}

class MessagesGaurd extends ConsumerWidget {
  final Widget child;
  const MessagesGaurd({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO add message for web
    if (platform.isWeb) return Placeholder();
    final auth = ref.watch(authProvider);

    final did = auth.value?.device?.did;
    if (did == null || did.isEmpty) {
      return const MessengerSetupPage();
    }
    final core = ref.watch(ecpCoreHolderProvider);
    if (core.isLoading) {
      return const Center(child: LoadingSpinner());
    }

    final ecp = ref.watch(asyncEcpClientProvider);
    if (ecp.isLoading) {
      debugPrint('[RequireEcp] ecpProvider loading');
      return const Center(child: LoadingSpinner());
    }
    if (ecp.hasError) {
      debugPrint('[RequireEcp] ecpProvider error');
      return _e(context);
    }
    debugPrint('[RequireEcp] ecpProvider satisfied');
    ref.watch(inboxPollingProvider);
    return child;
  }
}

class RequireEcp extends ConsumerWidget {
  final Widget child;
  const RequireEcp({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ecp = ref.watch(asyncEcpClientProvider);
    if (ecp.isLoading) {
      debugPrint('[RequireEcp] ecpProvider loading');
      return const Center(child: LoadingSpinner());
    }
    if (ecp.hasError) {
      debugPrint('[RequireEcp] ecpProvider error');
      return _e(context);
    }
    debugPrint('[RequireEcp] ecpProvider satisfied');
    ref.watch(inboxPollingProvider);
    return child;
  }
}
