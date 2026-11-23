import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/widgets/loading/loading_spinner.dart';

class ProfileRedirect extends ConsumerWidget {
  const ProfileRedirect({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final username = currentUser.user.username;
    final uid = currentUser.user.uid;
    if (username.isNotEmpty && uid.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/users/$username?uid=$uid');
      });
      return const Scaffold(body: Center(child: LoadingSpinner()));
    }
    return const Scaffold(body: Center(child: LoadingSpinner()));
  }
}
