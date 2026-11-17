import 'package:eko_app/utilities/api_constants.dart' as ac;
import 'package:eko_app/utilities/platform.dart' as platform;
import 'package:eko_app/utilities/supabase_session_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient get supabase => Supabase.instance.client;

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
}
