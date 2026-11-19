import 'package:eko_app/utilities/api_constants.dart' as ac;
import 'package:eko_app/utilities/platform.dart' as platform;
import 'package:eko_app/utilities/supabase_session_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient get supabase => Supabase.instance.client;

/// The session only refreshes itself while the app is in the foreground, so a
/// backgrounded app woken by a push would otherwise send an expired token.
Future<String?> freshAccessToken() async {
  final session = supabase.auth.currentSession;
  if (session == null || !session.isExpired) return session?.accessToken;
  return (await supabase.auth.refreshSession()).session?.accessToken;
}

// Supabase.instance asserts until it is initialized, so it can't tell
var _initialized = false;
bool get supabaseInitialized => _initialized;

/// [background] is for headless push engines, which have no activity to
/// receive auth deep links.
Future<void> initSupabase({bool background = false}) async {
  final projectRef = Uri.parse(ac.supabaseUrl).host.split('.').first;
  await Supabase.initialize(
    url: ac.supabaseUrl,
    anonKey: ac.supabaseKey,
    authOptions: platform.isLinux
        ? FlutterAuthClientOptions(
            authFlowType: AuthFlowType.implicit,
            detectSessionInUri: !background,
            localStorage: ReliableSupabaseSessionStorage(
              persistSessionKey: 'sb-$projectRef-auth-token',
            ),
          )
        : FlutterAuthClientOptions(
            authFlowType: AuthFlowType.implicit,
            detectSessionInUri: !background,
          ),
  );
  _initialized = true;
}

/// For the push engine, which only has Supabase while it uses it.
Future<void> disposeSupabase() async {
  if (!_initialized) return;
  _initialized = false;
  await Supabase.instance.dispose();
}
