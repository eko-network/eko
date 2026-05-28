import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/ecp_runtime_provider.dart';
import 'package:eko_app/widgets/loading/loading_spinner.dart';

class RequireAuth extends ConsumerWidget {
  final Widget child;
  const RequireAuth({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = ref.watch(currentUserProvider);

    if (auth.isLoading) {
      return const Center(child: LoadingSpinner());
    }
    if (auth.uid == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/');
      });
      return const Center(child: LoadingSpinner());
    }
    if (user.user.uid.isEmpty) {
      return const Center(child: LoadingSpinner());
    }
    if (!kIsWeb) {
      final ecpReady = ref.watch(ecpRuntimeReadyProvider);
      if (!ecpReady) {
        return const Center(child: LoadingSpinner());
      }
    } else if (auth.did == null) {
      return const Center(child: LoadingSpinner());
    }
    return child;
  }
}
