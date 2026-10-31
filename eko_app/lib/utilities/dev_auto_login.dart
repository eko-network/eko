import 'dart:io';

import 'package:eko_app/utilities/platform.dart' as platform;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Debug builds on Linux only: signs in with EKO_DEV_EMAIL / EKO_DEV_PASSWORD
/// so test windows can be started already logged in (see scripts/dev.sh app).
/// Read from the environment rather than arguments so the password stays out
/// of `ps` and shell history.
Future<void> devAutoLogin() async {
  if (!kDebugMode || !platform.isLinux) return;
  final email = Platform.environment['EKO_DEV_EMAIL'];
  final password = Platform.environment['EKO_DEV_PASSWORD'];
  if (email == null || email.isEmpty || password == null) return;

  final auth = Supabase.instance.client.auth;
  final current = auth.currentUser;
  if (current != null) {
    if (current.email != email) {
      debugPrint(
        '[DevAutoLogin] already signed in as ${current.email}, not $email',
      );
    }
    return;
  }
  try {
    await auth.signInWithPassword(email: email, password: password);
    debugPrint('[DevAutoLogin] signed in as $email');
  } catch (e) {
    debugPrint('[DevAutoLogin] sign in as $email failed: $e');
  }
}
