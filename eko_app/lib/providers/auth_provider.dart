import 'dart:convert';
import 'dart:typed_data';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/utilities/device_uid_service.dart';
import 'package:eko_app/utilities/ecp_ref.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eko_app/types/auth.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/utilities/shared_pref_service.dart';
import 'package:eko_app/interfaces/notification_helper.dart';
import 'package:eko_app/interfaces/user.dart' as user;
import 'package:eko_app/utilities/gauth/supabase_google_oauth.dart';
import 'package:eko_app/utilities/platform.dart' as platform;

part '../generated/providers/auth_provider.g.dart';

Future<void>? _registerNotificationsInFlight;

Map<String, dynamic>? decodeJwtPayloadMap(String? accessToken) {
  if (accessToken == null || accessToken.isEmpty) return null;
  final parts = accessToken.split('.');
  if (parts.length != 3) return null;
  try {
    var normalized = parts[1].replaceAll('-', '+').replaceAll('_', '/');
    final pad = normalized.length % 4;
    if (pad == 1) return null;
    if (pad != 0) {
      normalized = normalized.padRight(normalized.length + (4 - pad), '=');
    }
    final decoded = jsonDecode(utf8.decode(base64Decode(normalized)));
    if (decoded is! Map) return null;
    return Map<String, dynamic>.from(decoded);
  } catch (_) {
    return null;
  }
}

void _debugPrintJwtPayload(String accessToken) {
  if (!kDebugMode) return;
  final map = decodeJwtPayloadMap(accessToken);
  if (map == null) {
    debugPrint('JWT debug: decode failed or invalid token');
    return;
  }
  debugPrint('JWT debug: full payload JSON: ${jsonEncode(map)}');
  debugPrint(
    'JWT debug: app_metadata=${map['app_metadata']} user_metadata keys=${map['user_metadata'] is Map ? (map['user_metadata'] as Map).keys.toList() : map['user_metadata']}',
  );
}

String? _didFromDynamic(Object? v) {
  if (v is String && v.isNotEmpty) return v;
  return null;
}

String? didFromAccessTokenClaims(String? accessToken) {
  final map = decodeJwtPayloadMap(accessToken);
  if (map == null) return null;
  final app = map['app_metadata'];
  if (app is Map) {
    final nested = _didFromDynamic(app['did']);
    if (nested != null) return nested;
  }
  return _didFromDynamic(map['did']);
}

String? didFromSession(Session session) {
  final fromSdk = didFromUserAppMetadata(session.user);
  if (fromSdk != null) return fromSdk;
  return didFromAccessTokenClaims(session.accessToken);
}

void _debugPrintSupabaseBearer(Session? session) {
  if (!kDebugMode) return;
  final token = session?.accessToken;
  if (token == null || token.isEmpty) return;
  debugPrint('Supabase Bearer JWT: Bearer $token');
  _debugPrintJwtPayload(token);
  if (session != null) {
    debugPrint(
      'JWT debug: SDK session.user.appMetadata=${session.user.appMetadata}',
    );
  }
}

String? didFromUserAppMetadata(User user) {
  final v = user.appMetadata['did'];
  if (v is String && v.isNotEmpty) return v;
  return null;
}

class SignUpOutcome {
  const SignUpOutcome({this.errorCode, this.needsEmailVerification = false});

  final String? errorCode;
  final bool needsEmailVerification;

  bool get isSuccess => errorCode == null;
}

void handleAuthError(Object e, BuildContext context) {
  debugPrint(e.toString());
  if (e is AuthApiException) {
    if (e.code == 'email_not_confirmed') {
      showSnackBar(
        text: '${AppLocalizations.of(context)!.error}: ${e.message}',
        context: context,
        variant: SnackBarVariant.destructive,
      );
    } else if (e.code == 'invalid_credentials') {
      showSnackBar(
        text: AppLocalizations.of(context)!.loginFailedBody,
        context: context,
        variant: SnackBarVariant.destructive,
      );
    } else if (e.code == 'same_password') {
      showSnackBar(
        text: AppLocalizations.of(context)!.newPasswordMustBeDifferent,
        context: context,
        variant: SnackBarVariant.destructive,
      );
    } else {
      showSnackBar(
        text: '${AppLocalizations.of(context)!.error}: ${e.message}',
        context: context,
        variant: SnackBarVariant.destructive,
      );
    }
  } else {
    showSnackBar(
      text: AppLocalizations.of(context)!.defaultErrorTitle,
      context: context,
      variant: SnackBarVariant.destructive,
    );
  }
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AuthModel build() {
    _init();
    return AuthModel.loading();
  }

  void _init() {
    final currentSession = supabase.auth.currentSession;
    if (currentSession != null) {
      _debugPrintSupabaseBearer(currentSession);
      final user = currentSession.user;
      state = AuthModel(
        uid: user.id,
        isLoading: false,
        email: user.email,
        emailVerified: user.emailConfirmedAt != null,
        creationTime: DateTime.tryParse(user.createdAt),
        did: didFromSession(currentSession),
      );
      registerDeviceIfNeeded();
    }

    supabase.auth.onAuthStateChange.listen(
      (data) {
        final session = data.session;
        if (session == null) {
          state = AuthModel.signedOut();
        } else {
          _debugPrintSupabaseBearer(session);
          if (data.event == AuthChangeEvent.passwordRecovery) {
            final user = session.user;
            state = state.copyWith(
              uid: user.id,
              isLoading: false,
              email: user.email,
              emailVerified: user.emailConfirmedAt != null,
              creationTime: DateTime.tryParse(user.createdAt),
              pendingPasswordRecovery: true,
              did: didFromSession(session),
            );
          } else {
            final user = session.user;
            state = state.copyWith(
              uid: user.id,
              isLoading: false,
              email: user.email,
              emailVerified: user.emailConfirmedAt != null,
              creationTime: DateTime.tryParse(user.createdAt),
              pendingPasswordRecovery: false,
              did: didFromSession(session),
            );
            if (data.event == AuthChangeEvent.signedIn) {
              registerDeviceIfNeeded();
              // This throws on linux but appears to have to affect on android
              if (!platform.isLinux) {
                // ios typically opens an in-app web view, so it doesnt get dismissed otherwise
                closeInAppWebView();
              }
            }
          }
        }
      },
      onError: (error) {
        debugPrint('Auth state change error: $error (${error.runtimeType})');
        if (error is AuthException) {
          supabase.auth.signOut().catchError((e) {
            debugPrint('Error signing out after auth error: $e');
          });
        }
        state = AuthModel.signedOut();
      },
    );
  }

  void clearPasswordRecovery() {
    state = state.copyWith(pendingPasswordRecovery: false);
  }

  void syncDeviceIdFromJwt() {
    final session = supabase.auth.currentSession;
    if (session == null) return;
    state = state.copyWith(did: didFromSession(session));
  }

  Future<void> signIn({required String email, required String password}) async {
    await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signInWithGoogle() async {
    await signInWithGoogleOAuth(supabase.auth);
  }

  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
    required String username,
    required String name,
    required String birthday,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'username': username,
          'name': name,
          'birthday': birthday,
          'bio': '',
          'is_verified': false,
        },
        emailRedirectTo: (platform.isAndroid || platform.isIOS)
            ? c.appURL
            : c.verifyEmailURL,
      );
      final user = response.user;
      final needsEmailVerification =
          response.session == null || user?.emailConfirmedAt == null;
      return SignUpOutcome(needsEmailVerification: needsEmailVerification);
    } on AuthException catch (e) {
      debugPrint(e.message);
      final msg = e.message.toLowerCase();
      if (msg.contains('already registered') ||
          msg.contains('already been registered')) {
        return const SignUpOutcome(errorCode: 'email-already-in-use');
      }
      if (msg.contains('invalid email')) {
        return const SignUpOutcome(errorCode: 'invalid-email');
      }
      if (msg.contains('password') && msg.contains('6')) {
        return const SignUpOutcome(errorCode: 'weak-password');
      }
      return const SignUpOutcome(errorCode: 'unknown');
    } catch (e) {
      debugPrint(e.toString());
      return const SignUpOutcome(errorCode: 'unknown');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final uid = state.uid;
      if (uid == null) return;
      await supabase.rpc('delete_user');
      await supabase.auth.signOut();
    } catch (e) {
      debugPrint('Error deleting account: $e');
    }
  }

  Future<void> sendEmailVerification(String email) async {
    try {
      await supabase.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: c.verifyEmailURL,
      );
    } catch (e) {
      debugPrint('Error sending email verification: $e');
    }
  }

  Future<void> refreshEmailVerification() async {
    try {
      await supabase.auth.refreshSession();
      final session = supabase.auth.currentSession;
      final user = session?.user;
      if (user != null && session != null) {
        state = state.copyWith(
          emailVerified: user.emailConfirmedAt != null,
          did: didFromSession(session),
        );
      }
    } catch (e) {
      debugPrint('Error refreshing email verification: $e');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  Future<void> updateEmailBeforeVerify(String newEmail) async {
    await supabase.auth.updateUser(
      UserAttributes(email: newEmail.trim()),
    );
  }

  String? _oauthAvatarUrl() {
    final meta = supabase.auth.currentUser?.userMetadata;
    if (meta == null) return null;
    String? str(Object? v) {
      if (v == null) return null;
      final s = v is String ? v : v.toString();
      final t = s.trim();
      return t.isEmpty ? null : t;
    }

    return str(meta['avatar_url']) ??
        str(meta['picture']) ??
        str(meta['avatarUrl']);
  }

  Future<SignUpOutcome> createGoogleProfile({
    required String username,
    required String name,
    required String birthday,
  }) async {
    try {
      // Parse birthday string MM/DD/YYYY → date expected by the RPC
      final parts = birthday.split('/');
      final birthdayDate = parts.length == 3
          ? '${parts[2]}-${parts[0].padLeft(2, '0')}-${parts[1].padLeft(2, '0')}'
          : birthday;

      final avatarUrl = _oauthAvatarUrl();

      final response = await supabase.rpc(
        'create_google_profile',
        params: {
          'p_username': username,
          'p_name': name,
          'p_birthday': birthdayDate,
          'p_profile_picture': avatarUrl,
        },
      );
      if (response is! List || response.isEmpty) {
        return const SignUpOutcome(errorCode: 'unknown');
      }
      final row = Map<String, dynamic>.from(response.first as Map);
      if (row['success'] != true) {
        final msg = (row['error_message'] ?? '').toString().toLowerCase();
        if (msg.contains('username')) {
          return const SignUpOutcome(errorCode: 'username-taken');
        }
        return const SignUpOutcome(errorCode: 'unknown');
      }
      if (avatarUrl != null) {
        try {
          await supabase.auth.updateUser(
            UserAttributes(data: {'profile_picture': avatarUrl}),
          );
        } catch (e) {
          debugPrint('createGoogleProfile auth metadata sync: $e');
        }
      }
      return const SignUpOutcome();
    } on AuthException catch (e) {
      debugPrint('createGoogleProfile auth error: ${e.message}');
      return const SignUpOutcome(errorCode: 'unknown');
    } catch (e) {
      debugPrint('createGoogleProfile error: $e');
      return const SignUpOutcome(errorCode: 'unknown');
    }
  }

  Future<void> registerDeviceIfNeeded() async {
    final uid = state.uid;
    if (uid == null || uid.isEmpty) return;
    if (state.did != null) return;

    try {
      final deviceUid = DeviceUidService.getOrCreate();
      final credentialIdentity = Uint8List.fromList(utf8.encode(deviceUid));

      final identity = await ecp.initializeIdentity(
        credentialIdentity: credentialIdentity,
      );

      await supabase.rpc('register_device', params: {
        'p_did': deviceUid,
        'p_credential_identity': base64Encode(identity.credentialIdentity),
        'p_signer_public_key': base64Encode(identity.signerPublicKey),
      });

      if (identity.keyPackages.isNotEmpty) {
        await supabase.rpc('add_key_packages', params: {
          'p_did': deviceUid,
          'p_key_packages': identity.keyPackages.map(base64Encode).toList(),
        });
      }

      await supabase.auth.refreshSession();
      final session = supabase.auth.currentSession;
      if (session != null) {
        state = state.copyWith(did: didFromSession(session));
      }
    } catch (e) {
      debugPrint('Error registering device: $e');
    }
  }

  Future<void> registerNotificationsIfNeeded() async {
    final uid = state.uid;
    if (uid == null || uid.isEmpty) return;
    if (_registerNotificationsInFlight != null) {
      await _registerNotificationsInFlight;
      return;
    }
    _registerNotificationsInFlight = _registerNotificationsWork(uid);
    try {
      await _registerNotificationsInFlight;
    } finally {
      _registerNotificationsInFlight = null;
    }
  }

  Future<void> _registerNotificationsWork(String uid) async {
    try {
      await NotificationHelper.setupNotifications();
      await user.addDeviceNotificationToken(uid);
    } catch (e) {
      debugPrint('Error registering notifications: $e');
    }
  }

  Future<void> refreshDeviceNotificationTokenIfNeeded() async {
    final uid = state.uid;
    if (uid == null || uid.isEmpty) return;
    if (!PrefsService.notificationsEnabled) return;
    await user.refreshDeviceNotificationTokenIfNeeded(uid);
  }
}
