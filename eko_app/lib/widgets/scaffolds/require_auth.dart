import 'package:eko_app/utilities/device_uid_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:eko_app/widgets/loading/loading_spinner.dart';

Future<void>? _ensureDeviceJwtInFlight;

Future<void> _ensureDeviceClaimInJwt(WidgetRef ref) async {
  if (_ensureDeviceJwtInFlight != null) {
    await _ensureDeviceJwtInFlight;
    return;
  }
  _ensureDeviceJwtInFlight = () async {
    try {
      await supabase.auth.refreshSession();
    } catch (e) {
      debugPrint('refreshSession before register_device: $e');
    }
    ref.read(authProvider.notifier).syncDeviceIdFromJwt();
    if (ref.read(authProvider).did != null) return;

    await supabase.rpc('register_device',
        params: {'p_did': DeviceUidService.getOrCreate()});
    try {
      await supabase.auth.refreshSession();
    } catch (e) {
      debugPrint('refreshSession after register_device: $e');
    }
    ref.read(authProvider.notifier).syncDeviceIdFromJwt();
  }();
  try {
    await _ensureDeviceJwtInFlight;
  } finally {
    _ensureDeviceJwtInFlight = null;
  }
}

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
    if (!kIsWeb && auth.did == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) return;
        await _ensureDeviceClaimInJwt(ref);
      });
      return const Center(child: LoadingSpinner());
    }
    return child;
  }
}
