import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/widgets/loading/loading_spinner.dart';

class RequireNoAuth extends ConsumerWidget {
  final Widget child;
  const RequireNoAuth({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (auth.isLoading) {
      return const Center(child: LoadingSpinner());
    }
    if (auth.value?.uid != null) {
      debugPrint('[RequireNoAuth] User Signed In');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/feed');
      });
      return const Center(child: LoadingSpinner());
    }
    return child;
  }
}
