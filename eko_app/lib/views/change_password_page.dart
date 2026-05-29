import 'package:eko_app/widgets/scaffolds/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/widgets/scaffolds/eko_app_bar.dart';
import 'package:eko_app/widgets/auth/auth_button.dart';
import 'package:eko_app/widgets/auth/auth_divider.dart';
import 'package:eko_app/widgets/auth/create_password.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:eko_app/utilities/constants.dart' as c;

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final newPasswordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();
  bool isLoading = false;
  bool requirePasswordMatch = true;

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    newPasswordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final l10n = AppLocalizations.of(context)!;
    if (!isValidSimplePassword(
      newPasswordController.text,
      confirmPasswordController.text,
      requireMatch: requirePasswordMatch,
    )) {
      showSnackBar(
        text: l10n.weakPasswordBody,
        context: context,
        variant: SnackBarVariant.destructive,
      );
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() => isLoading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .updatePassword(newPasswordController.text);
    } catch (e) {
      debugPrint(e.toString());
      setState(() => isLoading = false);
      if (!mounted) return;
      handleAuthError(e, context);
      return;
    }
    setState(() => isLoading = false);
    if (!mounted) return;
    final username = ref.read(currentUserProvider).user.username;
    showSnackBar(text: l10n.passwordChangedBody, context: context);
    // ref.read(authProvider.notifier).clearPasswordRecovery();
    context.goNamed(
      'user_settings',
      pathParameters: {'username': username},
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      contrainBody: true,
      appBar: const EkoAppBar(),
      body: Center(
        child: SizedBox(
          width: width,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.symmetric(
              horizontal: width * c.authPaddingHorizontal,
            ),
            children: [
              SizedBox(height: height * .04),
              SizedBox(
                height: height * .08,
                child: Align(
                  child: Text(
                    l10n.changePassword,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const AuthDivider(indent: 20, endIndent: 20),
              SizedBox(height: height * .02),
              CreatePassword(
                passwordController: newPasswordController,
                confirmPasswordController: confirmPasswordController,
                passwordFocus: newPasswordFocus,
                confirmPasswordFocus: confirmPasswordFocus,
                onRequirePasswordMatchChanged: (requireMatch) {
                  requirePasswordMatch = requireMatch;
                },
              ),
              SizedBox(height: c.authSectionSpacing),
              AuthButton.primary(
                label: l10n.changePassword,
                isLoading: isLoading,
                onPressed: isLoading ? null : _submit,
              ),
              SizedBox(height: height * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
