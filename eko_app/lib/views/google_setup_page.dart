import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:eko_app/interfaces/user.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:eko_app/widgets/scaffolds/app_scaffold.dart';
import 'package:eko_app/widgets/scaffolds/eko_app_bar.dart';
import 'package:eko_app/widgets/auth/auth_button.dart';
import 'package:eko_app/widgets/auth/auth_divider.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:eko_app/widgets/inputs/custom_input_field.dart';
import 'package:eko_app/widgets/inputs/username_check_display.dart';

class GoogleSetupPage extends ConsumerStatefulWidget {
  const GoogleSetupPage({super.key});

  @override
  ConsumerState<GoogleSetupPage> createState() => _GoogleSetupPageState();
}

class _GoogleSetupPageState extends ConsumerState<GoogleSetupPage> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final monthController = TextEditingController();
  final dayController = TextEditingController();
  final yearController = TextEditingController();

  final nameFocus = FocusNode();
  final usernameFocus = FocusNode();
  final monthFocus = FocusNode();
  final dayFocus = FocusNode();
  final yearFocus = FocusNode();
  final keyFocus = FocusNode();

  bool usernameValid = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final googleName =
        supabase.auth.currentUser?.userMetadata?['full_name'] as String? ?? '';
    nameController.text = googleName;
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    monthController.dispose();
    dayController.dispose();
    yearController.dispose();
    nameFocus.dispose();
    usernameFocus.dispose();
    monthFocus.dispose();
    dayFocus.dispose();
    yearFocus.dispose();
    keyFocus.dispose();
    super.dispose();
  }

  void onKey(KeyEvent event) {
    if (monthFocus.hasFocus) {
      if (monthController.text.length == 2 &&
          event.logicalKey.keyLabel != 'Backspace') {
        dayFocus.requestFocus();
        dayController.text = event.character ?? '';
      }
    } else if (dayFocus.hasFocus) {
      if (dayController.text.length == 2 &&
          event.logicalKey.keyLabel != 'Backspace') {
        yearFocus.requestFocus();
        yearController.text = event.character ?? '';
      } else if (event.logicalKey.keyLabel == 'Backspace' &&
          dayController.text.isEmpty) {
        monthFocus.requestFocus();
      }
    } else if (yearFocus.hasFocus) {
      if (event.logicalKey.keyLabel == 'Backspace' &&
          yearController.text.isEmpty) {
        dayFocus.requestFocus();
      }
    }
  }

  DateTime? getDateTime() {
    try {
      final day = int.tryParse(dayController.text);
      final month = int.tryParse(monthController.text);
      final year = int.tryParse(yearController.text);
      if (day == null || month == null || year == null) return null;
      if (day < 1 || day > 31) return null;
      if (month < 1 || month > 12) return null;
      if (year < 1900 || year > DateTime.now().year) return null;
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  void formatTime(DateTime? birthday) {
    if (birthday != null) {
      final s = DateFormat('MM/dd/yyyy').format(birthday);
      final parts = s.split('/');
      monthController.text = parts[0];
      dayController.text = parts[1];
      yearController.text = parts[2];
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final birthday = getDateTime();
    if (birthday == null) {
      showSnackBar(
        text: l10n.invalidBirthdayBody,
        context: context,
        variant: SnackBarVariant.destructive,
      );
      return;
    }
    if (birthday.compareTo(
          DateTime.now().subtract(const Duration(days: 13 * 365)),
        ) >=
        0) {
      showSnackBar(
        text: l10n.tooYoungBody,
        context: context,
        variant: SnackBarVariant.destructive,
      );
      return;
    }
    if (nameController.text.trim().isEmpty) {
      nameFocus.requestFocus();
      return;
    }
    if (nameController.text.trim().length > c.maxNameChars) {
      showSnackBar(
        text: l10n.tooManyChar,
        context: context,
        variant: SnackBarVariant.destructive,
      );
      nameFocus.requestFocus();
      return;
    }
    if (!usernameValid) {
      usernameFocus.requestFocus();
      return;
    }
    if (!await isUsernameAvailable(usernameController.text.trim())) {
      if (!mounted) return;
      showSnackBar(
        text: l10n.usernameTakenBody,
        context: context,
        variant: SnackBarVariant.destructive,
      );
      usernameController.clear();
      usernameFocus.requestFocus();
      return;
    }

    setState(() => isLoading = true);
    try {
      final birthdayStr =
          '${monthController.text}/${dayController.text}/${yearController.text}';
      final outcome = await ref
          .read(authProvider.notifier)
          .createGoogleProfile(
            username: usernameController.text.trim(),
            name: nameController.text.trim(),
            birthday: birthdayStr,
          );
      if (!mounted) return;
      if (!outcome.isSuccess) {
        if (outcome.errorCode == 'username-taken') {
          showSnackBar(
            text: l10n.usernameTakenBody,
            context: context,
            variant: SnackBarVariant.destructive,
          );
          usernameController.clear();
          usernameFocus.requestFocus();
        } else {
          showSnackBar(
            text: l10n.defaultErrorBody,
            context: context,
            variant: SnackBarVariant.destructive,
          );
        }
        return;
      }
      ref.read(needsProfileSetupProvider.notifier).state = false;
      await ref.read(currentUserProvider.notifier).reload();
      if (!mounted) return;
      context.go('/feed');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _cancel() async {
    await ref.read(currentUserProvider.notifier).signOut();
    if (!mounted) return;
    ref.read(needsProfileSetupProvider.notifier).state = false;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: AppScaffold(
        appBar: EkoAppBar(onBack: _cancel),
        body: Center(
          child: SizedBox(
            width: width,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * c.authPaddingHorizontal,
              ),
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  SizedBox(height: height * 0.01),
                  SizedBox(
                    height: height * .08,
                    child: Align(
                      child: Text(
                        l10n.createAnAccount,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const AuthDivider(indent: 20, endIndent: 20),
                  SizedBox(height: height * 0.02),
                  CustomInputField(
                    autofillHints: [AutofillHints.name],
                    focus: nameFocus,
                    label: l10n.name,
                    controller: nameController,
                    inputType: TextInputType.text,
                  ),
                  CustomInputField(
                    autofillHints: [AutofillHints.username],
                    focus: usernameFocus,
                    label: l10n.userName,
                    controller: usernameController,
                    inputType: TextInputType.text,
                  ),
                  UsernameCheckDisplay(
                    controller: usernameController,
                    focus: usernameFocus,
                    onValidate: (val) {
                      usernameValid = val;
                    },
                  ),
                  const SizedBox(height: c.authElementSpacing),
                  Text(
                    l10n.birthday,
                    style: const TextStyle(
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  KeyboardListener(
                    onKeyEvent: onKey,
                    focusNode: keyFocus,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.month),
                            CustomInputField(
                              autofillHints: [AutofillHints.birthdayMonth],
                              filter: r'[0-9]*',
                              showCounter: false,
                              maxLen: 2,
                              padding: false,
                              width: width * 0.15,
                              focus: monthFocus,
                              controller: monthController,
                              inputType: TextInputType.number,
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.03,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.day),
                              CustomInputField(
                                autofillHints: [AutofillHints.birthdayDay],
                                filter: r'[0-9]*',
                                showCounter: false,
                                maxLen: 2,
                                padding: false,
                                width: width * 0.15,
                                focus: dayFocus,
                                controller: dayController,
                                inputType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.year),
                            CustomInputField(
                              autofillHints: [AutofillHints.birthdayYear],
                              filter: r'[0-9]*',
                              showCounter: false,
                              maxLen: 4,
                              padding: false,
                              width: width * 0.3,
                              focus: yearFocus,
                              controller: yearController,
                              inputType: TextInputType.number,
                            ),
                          ],
                        ),
                        const SizedBox(width: 5),
                        Column(
                          children: [
                            const Text(''),
                            IconButton(
                              onPressed: () async {
                                formatTime(
                                  await showDatePicker(
                                    context: context,
                                    initialEntryMode:
                                        DatePickerEntryMode.calendarOnly,
                                    initialDate: getDateTime(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  ),
                                );
                              },
                              icon: const Icon(CupertinoIcons.calendar),
                              iconSize: 35,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    l10n.birthdayExplanation,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: height * 0.04),
                  AuthButton.primary(
                    label: l10n.cont,
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
