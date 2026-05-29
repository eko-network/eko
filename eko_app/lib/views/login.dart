import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/widgets/common/download_button.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:eko_app/interfaces/user.dart' as user;
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/views/verify_email_page.dart';
import 'package:eko_app/widgets/auth/google_sign_in_button.dart';
import 'package:eko_app/widgets/common/icons.dart';
import 'package:eko_app/widgets/inputs/custom_input_field.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/widgets/scaffolds/app_scaffold.dart';
import 'package:eko_app/widgets/scaffolds/eko_app_bar.dart';
import 'package:eko_app/widgets/auth/auth_button.dart';
import 'package:eko_app/widgets/auth/auth_divider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  bool isLoading = false;
  bool isGoogleLoading = false;
  int _paneIndex = 0;

  @override
  void dispose() {
    emailFocus.dispose();
    passwordFocus.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> googleLoginPressed() async {
    setState(() {
      isGoogleLoading = true;
    });
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
    } on AuthException catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      showSnackBar(
        text: '${AppLocalizations.of(context)!.error}: ${e.message}',
        context: context,
        variant: SnackBarVariant.destructive,
      );
    } catch (e, st) {
      debugPrint('Google SignIn Error: $e\n$st');
      if (!mounted) return;
      if (ref.read(authProvider).value?.uid != null) return;
      // url_launcher throws a PlatformException on iOS if the Safari View Controller is closed
      if (e.toString().contains('PlatformException')) return;
      showSnackBar(
        text: AppLocalizations.of(context)!.defaultErrorTitle,
        context: context,
        variant: SnackBarVariant.destructive,
      );
    } finally {
      if (mounted) {
        setState(() {
          isGoogleLoading = false;
        });
      }
    }
  }

  void loginPressed() async {
    if (emailController.text == '') {
      emailFocus.requestFocus();
    } else if (passwordController.text == '') {
      passwordFocus.requestFocus();
    } else {
      setState(() {
        isLoading = true;
      });
      try {
        await ref.read(authProvider.notifier).signIn(
              email: emailController.text.trim(),
              password: passwordController.text,
            );
      } on AuthApiException catch (e) {
        debugPrint(e.toString());
        debugPrint('code: ${e.code}');

        if (mounted) {
          if (e.code == 'email_not_confirmed') {
            setState(() {
              _paneIndex = 1;
            });
          } else if (e.code == 'invalid_credentials') {
            // TODO Remove this after sufficent time for migration has passed
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext dialogContext) {
                final l10n = AppLocalizations.of(context)!;
                return AlertDialog(
                  backgroundColor: Theme.of(context).colorScheme.outlineVariant,
                  title: Text(l10n.loginFailedBody),
                  content: Text(l10n.requiredResetPasswordPrompt),
                  actions: <Widget>[
                    TextButton(
                      child: Text(l10n.back),
                      onPressed: () {
                        dialogContext.pop();
                      },
                    ),
                    TextButton(
                      child: Text(l10n.resetPassword),
                      onPressed: () {
                        dialogContext.pop();
                        forgotPasswordPressed(l10n.localeName);
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            handleAuthError(e, context);
          }
        }
      } catch (e) {
        debugPrint(e.toString());
        if (mounted) {
          showSnackBar(
              text: AppLocalizations.of(context)!.defaultErrorTitle,
              context: context,
              variant: SnackBarVariant.destructive);
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  void forgotPasswordPressed(String? countryCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isSending = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final l10n = AppLocalizations.of(context)!;
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.outlineVariant,
              title: Text(l10n.resetPassword),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomInputField(
                      autofillHints: [AutofillHints.email],
                      label: l10n.email,
                      controller: emailController,
                      inputType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(l10n.cancel),
                  onPressed: () {
                    context.pop();
                  },
                ),
                TextButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          setDialogState(() {
                            isSending = true;
                          });
                          await user.forgotPassword(
                            countryCode: countryCode,
                            email: emailController.text.trim(),
                          );

                          if (context.mounted) {
                            context.pop();
                            showSnackBar(
                              text: l10n.forgotPasswordBody,
                              context: context,
                            );
                          }
                        },
                  child: isSending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.sendResetLink),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      appBar: EkoAppBar(
        onBack: _paneIndex == 1 ? () => setState(() => _paneIndex = 0) : null,
      ),
      floatingActionButton: downloadButtonIfWeb(),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Center(
          child: SizedBox(
            width: c.widthGetter(context),
            child: IndexedStack(
              index: _paneIndex,
              children: [
                SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.symmetric(
                    horizontal: width * c.authPaddingHorizontal,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: height * .04),
                      SizedBox(
                        height: height * .22,
                        width: width * 0.7,
                        child: Eko(useDefault: true),
                      ),
                      SizedBox(height: height * .04),
                      AutofillGroup(
                        child: Column(
                          children: [
                            CustomInputField(
                              autofillHints: [AutofillHints.email],
                              focus: emailFocus,
                              label: l10n.email,
                              controller: emailController,
                              inputType: TextInputType.emailAddress,
                            ),
                            CustomInputField(
                              autofillHints: [AutofillHints.password],
                              textInputAction: TextInputAction.go,
                              onEditingComplete: () => loginPressed(),
                              focus: passwordFocus,
                              label: l10n.password,
                              controller: passwordController,
                              inputType: TextInputType.visiblePassword,
                              password: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: c.authElementSpacing),
                      AuthButton.primary(
                        label: l10n.logIn,
                        isLoading: isLoading,
                        onPressed: isLoading ? null : loginPressed,
                      ),
                      SizedBox(
                        width: c.widthGetter(context) * 0.9,
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () => forgotPasswordPressed(l10n.localeName),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onSurface,
                          ),
                          child: Text(
                            l10n.forgotPassword,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: c.authSectionSpacing),
                      const AuthDivider(indent: 20, endIndent: 20),
                      const SizedBox(height: c.authElementSpacing),
                      GoogleSignInButton(
                        onPressed: isLoading ? null : googleLoginPressed,
                        isLoading: isGoogleLoading,
                      ),
                      SizedBox(height: height * 0.04),
                    ],
                  ),
                ),
                VerifyEmailView(
                  email: emailController.text.trim(),
                  passwordController: passwordController,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
