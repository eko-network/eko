import 'package:eko_app/widgets/scaffolds/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/widgets/scaffolds/eko_app_bar.dart';
import 'package:eko_app/widgets/auth/auth_button.dart';
import 'package:eko_app/widgets/auth/auth_divider.dart';
import 'package:eko_app/widgets/errors/dialogs.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:eko_app/widgets/inputs/custom_input_field.dart';
import 'package:eko_app/utilities/constants.dart' as c;

final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class ChangeEmailPage extends ConsumerStatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  ConsumerState<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends ConsumerState<ChangeEmailPage> {
  final currentPasswordController = TextEditingController();
  final newEmailController = TextEditingController();
  final currentPasswordFocus = FocusNode();
  final newEmailFocus = FocusNode();
  bool isLoading = false;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newEmailController.dispose();
    currentPasswordFocus.dispose();
    newEmailFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final l10n = AppLocalizations.of(context)!;
    final authEmail = ref.read(authProvider).value?.email;
    if (authEmail == null || authEmail.isEmpty) {
      showSnackBar(
        text: l10n.defaultErrorBody,
        context: context,
        variant: SnackBarVariant.destructive,
      );
      return;
    }

    final trimmedNew = newEmailController.text.trim();
    if (trimmedNew.isEmpty) {
      newEmailFocus.requestFocus();
      return;
    }
    if (!_emailRegex.hasMatch(trimmedNew)) {
      showSnackBar(
        text: l10n.invalidEmailBody,
        context: context,
        variant: SnackBarVariant.destructive,
      );
      return;
    }
    if (trimmedNew.toLowerCase() == authEmail.toLowerCase()) {
      showSnackBar(
        text: l10n.invalidEmailBody,
        context: context,
        variant: SnackBarVariant.destructive,
      );
      return;
    }
    if (currentPasswordController.text.isEmpty) {
      currentPasswordFocus.requestFocus();
      return;
    }

    setState(() => isLoading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .signIn(email: authEmail, password: currentPasswordController.text);
    } catch (e) {
      if (mounted) handleAuthError(e, context);
      return;
    }

    try {
      await ref.read(authProvider.notifier).updateEmailBeforeVerify(trimmedNew);
      if (!mounted) return;
      setState(() => isLoading = false);
      await showMyDialog(
        l10n.changeEmailVerificationTitle,
        l10n.changeEmailVerificationBody,
        [l10n.ok],
        [
          () {
            context.pop();
            if (mounted) context.pop();
          },
        ],
        context,
      );
      return;
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      setState(() => isLoading = false);
      showSnackBar(
        text: l10n.defaultErrorBody,
        context: context,
        variant: SnackBarVariant.destructive,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currentEmail = ref.watch(authProvider).value?.email;

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
                    l10n.changeEmail,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const AuthDivider(indent: 20, endIndent: 20),
              SizedBox(height: height * .02),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: c.authElementSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.currentEmail,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        (currentEmail != null && currentEmail.isNotEmpty)
                            ? currentEmail
                            : '—',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomInputField(
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                focus: newEmailFocus,
                label: l10n.newEmail,
                controller: newEmailController,
                inputType: TextInputType.emailAddress,
                onEditingComplete: () => currentPasswordFocus.requestFocus(),
              ),
              CustomInputField(
                textInputAction: TextInputAction.done,
                focus: currentPasswordFocus,
                label: l10n.currentPassword,
                controller: currentPasswordController,
                inputType: TextInputType.visiblePassword,
                password: true,
                onEditingComplete: _submit,
              ),
              SizedBox(height: c.authSectionSpacing),
              AuthButton.primary(
                label: l10n.changeEmail,
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
