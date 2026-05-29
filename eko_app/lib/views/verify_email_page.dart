import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/widgets/auth/auth_button.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';

class VerifyEmailView extends ConsumerStatefulWidget {
  const VerifyEmailView({
    super.key,
    required this.email,
    required this.passwordController,
  });

  final String email;
  final TextEditingController passwordController;

  @override
  ConsumerState<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends ConsumerState<VerifyEmailView> {
  bool _resendLoading = false;
  bool _checkLoading = false;
  int _resendCountdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String? _effectiveEmail() {
    final e = widget.email.trim();
    if (e.isNotEmpty) return e;
    return null;
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendCountdown = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        if (mounted) setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resend() async {
    if (_resendLoading || _resendCountdown > 0) return;
    final email = _effectiveEmail();
    if (email == null || email.isEmpty) return;
    setState(() => _resendLoading = true);
    try {
      await ref.read(authProvider.notifier).sendEmailVerification(email);
      _startTimer();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) setState(() => _resendLoading = false);
    }
  }

  Future<void> _trySignIn() async {
    if (_checkLoading) return;
    final email = _effectiveEmail();
    if (email == null || email.isEmpty) return;
    if (widget.passwordController.text.isEmpty) {
      if (mounted) {
        showSnackBar(
          text: AppLocalizations.of(context)!.defaultErrorBody,
          context: context,
          variant: SnackBarVariant.destructive,
        );
      }
      return;
    }
    setState(() => _checkLoading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .signIn(email: email, password: widget.passwordController.text);
      if (mounted) context.go('/feed');
    } catch (e) {
      if (mounted) handleAuthError(e, context);
    } finally {
      if (mounted) setState(() => _checkLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = c.widthGetter(context);
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: c.maxAuthWidth),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.symmetric(
            horizontal: width * c.authPaddingHorizontal,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mail_lock_outlined,
                size: 100,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: c.authSectionSpacing),
              Text(
                l10n.verifyEmailTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: c.authElementSpacing),
              Text(
                l10n.verifyEmailBody,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: c.authSectionSpacing * 1.5),
              AuthButton.primary(
                label: _resendCountdown > 0
                    ? l10n.resendInSeconds(_resendCountdown)
                    : l10n.resendVerificationEmail,
                isLoading: _resendLoading,
                onPressed: (_resendLoading || _resendCountdown > 0)
                    ? null
                    : _resend,
              ),
              const SizedBox(height: c.authElementSpacing),
              AuthButton.secondary(
                label: l10n.iveVerifiedMyEmail,
                isLoading: _checkLoading,
                onPressed: _checkLoading ? null : _trySignIn,
              ),
              SizedBox(height: c.authSectionSpacing),
            ],
          ),
        ),
      ),
    );
  }
}
