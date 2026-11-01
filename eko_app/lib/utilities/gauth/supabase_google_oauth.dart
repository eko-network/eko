import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_google_oauth_stub.dart'
    if (dart.library.io) 'supabase_google_oauth_io.dart'
    as oauth;

Future<void> signInWithGoogleOAuth(GoTrueClient auth) =>
    oauth.signInWithGoogleOAuth(auth);
