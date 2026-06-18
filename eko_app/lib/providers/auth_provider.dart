import 'dart:async';
import 'package:eko_app/types/device.dart';
import 'package:eko_app/database/database.dart';
import 'package:eko_app/database/storage.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/utilities/device_uid_service.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:flutter/cupertino.dart';
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
  StreamSubscription? _authSub;
  @override
  Future<AuthModel> build() async {
    ref.onDispose(() {
      _authSub?.cancel();
    });
    final session = supabase.auth.currentSession;
    final AuthModel nextState;
    if (session != null) {
      nextState = await _stateFromSession(session);
    } else {
      nextState = AuthModel(uid: null);
    }
    _listenToAuthChanges();
    return nextState;
  }

  Future<AuthModel> _stateFromSession(Session session) async {
    debugPrint('[Auth] _stateFromSession called');
    final u = session.user;
    registerNotificationsIfNeeded(u.id);
    final model = AuthModel(
      uid: u.id,
      email: u.email,
      device: DeviceModel.fromSession(session),
    );
    debugPrint(
      '[Auth] _stateFromSession called\n\tuid: ${model.uid}\n\t\tdid: ${model.device?.did ?? 'null'}\n\t\tdat: ${model.device?.dat ?? 'null'}',
    );
    return model;
  }

  void _listenToAuthChanges() {
    _authSub = supabase.auth.onAuthStateChange.listen(
      (data) async {
        if (data.event == AuthChangeEvent.initialSession) return;
        final session = data.session;
        if (session == null) {
          debugPrint('[Auth] SignOut called');
          _cleanAfterSignOut();
          return;
        }

        if (state.isLoading) return;

        final isSameToken =
            state.value?.uid == session.user.id &&
            state.value?.email == session.user.email &&
            (platform.isWeb ||
                DeviceModel.fromSession(session) == state.value?.device);

        if (!isSameToken) {
          state = const AsyncValue.loading();
          state = await AsyncValue.guard(() => _stateFromSession(session));
        }
        if (!(data.event == AuthChangeEvent.passwordRecovery) &&
            data.event == AuthChangeEvent.signedIn &&
            !platform.isLinux) {
          closeInAppWebView();
        }
      },
      onError: (error) {
        debugPrint('Auth state change error: $error (${error.runtimeType})');
        if (error is AuthException) {
          supabase.auth.signOut().catchError((e) {
            debugPrint('Error signing out after auth error: $e');
          });
        }
        state = AsyncValue.data(AuthModel.signedOut());
      },
    );
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

  Future<void> signOut() async {
    final uid = state.value?.uid;
    if (uid != null) {
      await user.removeDeviceNotificationToken(uid);
      DeviceUidService.remove();
    }
    supabase.auth.signOut();
  }

  Future<void> _cleanAfterSignOut() async {
    await AppStorage(db).clear();
    state = AsyncValue.data(AuthModel.signedOut());
  }

  Future<void> deleteAccount() async {
    try {
      final uid = state.value?.uid;
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
    } catch (e) {
      debugPrint('Error refreshing email verification: $e');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> updateEmailBeforeVerify(String newEmail) async {
    await supabase.auth.updateUser(UserAttributes(email: newEmail.trim()));
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

  Future<void> registerNotificationsIfNeeded(String uid) async {
    if (uid.isEmpty) return;
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
    final uid = state.value?.uid;
    if (uid == null || uid.isEmpty) return;
    if (!PrefsService.notificationsEnabled) return;
    await user.refreshDeviceNotificationTokenIfNeeded(uid);
  }
}
