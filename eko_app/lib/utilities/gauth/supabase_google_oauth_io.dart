import 'dart:async';
import 'dart:io';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/utilities/platform.dart' as platform;
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> signInWithGoogleOAuth(GoTrueClient auth) async {
  if (platform.isMobile) {
    final launched = await auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: c.supabaseOAuthRedirectUrl,
      queryParams: {'prompt': 'select_account'},
    );
    if (!launched) {
      throw AuthException('Could not open browser for Google sign-in.');
    }
    return;
  }

  if (!platform.isDesktop) {
    await auth.signInWithOAuth(
      OAuthProvider.google,
      queryParams: {'prompt': 'select_account'},
    );
    return;
  }

  HttpServer? server;
  StreamSubscription<HttpRequest>? subscription;
  try {
    try {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    } on SocketException {
      throw AuthException(
        'Could not start a local sign-in callback server on 127.0.0.1.',
      );
    }

    final redirectTo = 'http://127.0.0.1:${server.port}/';
    const oauthDonePath = '/oauth-done';
    final completer = Completer<Uri>();

    Future<void> respondDoneHtml(HttpRequest request) async {
      request.response.statusCode = 200;
      request.response.headers.contentType = ContentType(
        'text',
        'html',
        charset: 'utf-8',
      );
      request.response.write(
        '<!DOCTYPE html><html><head><meta charset="utf-8">'
        '<title>eko</title>'
        '<style>body{font-family:sans-serif;display:flex;align-items:center;'
        'justify-content:center;height:100vh;margin:0;}'
        'p{color:#444;font-size:1.1rem;}</style>'
        '</head><body>'
        '<p>Sign-in complete. This window will close automatically.</p>'
        '<script>'
        'try { window.close(); } catch(e) {}'
        'setTimeout(() => {'
        '  document.querySelector("p").textContent = '
        '  "Sign-in complete! You can close this tab.";'
        '}, 100);'
        '</script>'
        '</body></html>',
      );
      await request.response.close();
    }

    subscription = server.listen((request) async {
      if (request.method != 'GET') {
        request.response.statusCode = 405;
        await request.response.close();
        return;
      }
      final uri = request.requestedUri;
      if (uri.queryParameters.containsKey('error')) {
        completer.completeError(
          AuthException(
            uri.queryParameters['error_description'] ??
                uri.queryParameters['error'] ??
                'OAuth error',
          ),
        );
        return;
      }
      final hasPkceCode = uri.queryParameters.containsKey('code');
      final hasImplicitTokens = uri.queryParameters.containsKey('access_token');
      if (hasPkceCode || hasImplicitTokens) {
        await respondDoneHtml(request);
        if (!completer.isCompleted) {
          completer.complete(uri);
        }
        return;
      }
      final path = uri.path.isEmpty ? '/' : uri.path;
      if (path == '/') {
        request.response.statusCode = 200;
        request.response.headers.contentType = ContentType(
          'text',
          'html',
          charset: 'utf-8',
        );
        request.response.write(
          '<!DOCTYPE html><html><head><meta charset="utf-8"><title>eko</title>'
          '</head><body>'
          '<script>'
          '(function(){'
          'var h=window.location.hash;'
          'var host=window.location.protocol+"//"+window.location.host;'
          'if(h&&h.length>1){'
          'window.location.replace(host+"$oauthDonePath?"+'
          'new URLSearchParams(h.slice(1)).toString());'
          'return;}'
          'var s=window.location.search;'
          'if(s&&s.length>1){'
          'window.location.replace(host+"$oauthDonePath"+s);'
          'return;}'
          'document.body.textContent="Waiting for sign-in…";'
          '})();'
          '</script></body></html>',
        );
        await request.response.close();
        return;
      }
      request.response.statusCode = 404;
      await request.response.close();
    });

    final launched = await auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectTo,
      queryParams: {'prompt': 'select_account'},
    );
    if (!launched) {
      throw AuthException('Could not open browser for Google sign-in.');
    }

    final callbackUri = await completer.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () => throw AuthException(
        'Google sign-in timed out waiting for the browser redirect.',
      ),
    );

    await auth.getSessionFromUrl(callbackUri);
  } finally {
    await subscription?.cancel();
    await server?.close(force: true);
  }
}
