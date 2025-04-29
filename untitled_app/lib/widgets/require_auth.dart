import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/providers/auth_provider.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/widgets/loading_spinner.dart';

class RequireAuth extends ConsumerWidget {
  final Widget child;
  const RequireAuth({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = ref.watch(currentUserProvider);
    if (auth.isLoading) {
      return Center(child: LoadingSpinner());
    }
    if (auth.uid == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
      return SizedBox.expand();
    }
    if (user.user.uid.isEmpty) {
      return Center(child: LoadingSpinner());
    }
    return child;
  }
}
