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

    return auth.when(data: (auth) {
      if (auth.uid == null) {
        debugPrint('[RequireAuth] authProvider not loading but uid==null');
        return _e(context);
      }
      if (user.user.uid.isEmpty) {
        debugPrint(
            '[RequireAuth] authProvider not loading but user.uid is empty');
        return Center(child: LoadingSpinner());
      }
      debugPrint('[RequireAuth] authProvider satisfied');
      return platform.isWeb ? child : RequireEcp(child: child);
    }, error: (_, __) {
      debugPrint('[RequireAuth] authProvider error');
      return _e(context);
    }, loading: () {
      debugPrint('[RequireAuth] authProvider loading');
      return Center(child: LoadingSpinner());
    });
  }
}

class RequireEcp extends ConsumerWidget {
  final Widget child;
  const RequireEcp({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ecp = ref.watch(asyncEcpClientProvider);
    return ecp.when(data: (_) {
      debugPrint('[RequireEcp] ecpProvider satisfied');
      return child;
    }, error: (_, __) {
      debugPrint('[RequireEcp] ecpProvider error');
      return _e(context);
    }, loading: () {
      debugPrint('[RequireEcp] ecpProvider loading');
      return Center(child: LoadingSpinner());
    });
  }
}
