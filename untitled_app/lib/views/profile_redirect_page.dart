import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/widgets/loading_spinner.dart';

class ProfileRedirect extends ConsumerWidget {
  const ProfileRedirect({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser.user.username.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/users/${currentUser.user.username}');
      });
      return const Scaffold(
        body: Center(
          child: LoadingSpinner(),
        ),
      );
    }
    return const Scaffold(
      body: Center(
        child: LoadingSpinner(),
      ),
    );
  }
}
