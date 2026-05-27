import 'package:ecp/ecp.dart';
import 'package:eko_app/utilities/supabase_ref.dart';

class SupabaseTokenProvider implements TokenProvider {
  @override
  Future<String?> getAccessToken() async {
    return supabase.auth.currentSession?.accessToken;
  }
}

Future<Map<String, String>> supabaseRequestAuthenticator() async {
  final token = supabase.auth.currentSession?.accessToken;
  if (token == null || token.isEmpty) {
    return {};
  }
  return {'Authorization': 'Bearer $token'};
}

final supabaseTokenProvider = SupabaseTokenProvider();
