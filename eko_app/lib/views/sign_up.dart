import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:eko_app/widgets/errors/dialogs.dart';
import 'package:eko_app/interfaces/user.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/nav_bar_provider.dart';
import 'package:eko_app/widgets/auth/create_password.dart';
import 'package:eko_app/widgets/auth/google_sign_in_button.dart';
import 'package:eko_app/widgets/inputs/username_check_display.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eko_app/widgets/inputs/custom_input_field.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/widgets/common/download_button.dart';
import 'package:eko_app/widgets/scaffolds/app_scaffold.dart';
import 'package:eko_app/widgets/scaffolds/eko_app_bar.dart';
import 'package:eko_app/widgets/auth/auth_button.dart';
import 'package:eko_app/widgets/auth/auth_divider.dart';
import 'package:eko_app/views/verify_email_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void _showWeakPassword(BuildContext context) {
  showSnackBar(
    text: AppLocalizations.of(context)!.weakPasswordBody,
    context: context,
    variant: SnackBarVariant.destructive,
  );
}

class SignUp extends ConsumerStatefulWidget {
  const SignUp({super.key});

  @override
  ConsumerState<SignUp> createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignUp> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final nameController = TextEditingController();
  final passwordFocus = FocusNode();
  final usernameFocus = FocusNode();
  final nameFocus = FocusNode();
  final monthFocus = FocusNode();
  final dayFocus = FocusNode();
  final yearFocus = FocusNode();
  final monthController = TextEditingController();
  final dayController = TextEditingController();
  final yearController = TextEditingController();
  final keyFocus = FocusNode();
  final emailFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  int index = 0;
  bool isGoogleLoading = false;

  @override
  void dispose() {
    confirmPasswordFocus.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailController.dispose();
    emailFocus.dispose();
    usernameController.dispose();
    usernameFocus.dispose();
    nameController.dispose();
    passwordFocus.dispose();
    nameFocus.dispose();
    monthFocus.dispose();
    dayFocus.dispose();
    yearFocus.dispose();
    monthController.dispose();
    dayController.dispose();
    yearController.dispose();
    keyFocus.dispose();
    super.dispose();
  }

  bool _handleError(String errorCode) {
    final l10n = AppLocalizations.of(context)!;
    switch (errorCode) {
      case 'username-taken':
        showSnackBar(
          text: l10n.usernameTakenBody,
          context: context,
          variant: SnackBarVariant.destructive,
        );
        usernameController.clear();
        setState(() {
          index = 0;
        });
        usernameFocus.requestFocus();
        break;
      case 'invalid-email':
        showSnackBar(
          text: l10n.invalidEmailBody,
          context: context,
          variant: SnackBarVariant.destructive,
        );
        break;
      case 'weak-password':
        _showWeakPassword(context);
        break;
      case 'email-already-in-use':
        showMyDialog(
          l10n.emailAlreadyInUseTitle,
          l10n.emailAlreadyInUseBody,
          [l10n.logIn, l10n.tryAgain],
          [
            () {
              context.pop();
              context.go('/');
            },
            context.pop,
          ],
          context,
        );
        break;
      default:
        showSnackBar(
          text: l10n.defaultErrorBody,
          context: context,
          variant: SnackBarVariant.destructive,
        );
        break;
    }
    return false;
  }

  Future<bool> signUp() async {
    ref.read(navBarProvider.notifier).enable();
    if (await isUsernameAvailable(usernameController.text.trim())) {
      final outcome = await ref
          .read(authProvider.notifier)
          .signUp(
            email: emailController.text.trim(),
            password: passwordController.text,
            username: usernameController.text.trim(),
            name: nameController.text,
            birthday:
                '${monthController.text}/${dayController.text}/${yearController.text}',
          );
      if (!outcome.isSuccess) {
        return _handleError(outcome.errorCode!);
      }
      if (!mounted) return true;
      if (outcome.needsEmailVerification) {
        setState(() => index = 2);
        return true;
      }
      context.go('/feed');
      return true;
    } else {
      _handleError('username-taken');
    }
    return false;
  }

  Future<void> signInWithGoogle() async {
    setState(() => isGoogleLoading = true);
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
    } on AuthException catch (e) {
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
        setState(() => isGoogleLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: AppScaffold(
        appBar: EkoAppBar(
          onBack: () {
            if (index == 2) {
              context.go('/');
            } else if (index == 1) {
              setState(() => index = 0);
            } else {
              context.go('/');
            }
          },
        ),
        floatingActionButton: downloadButtonIfWeb(),
        body: Center(
          child: SizedBox(
            width: c.widthGetter(context),
            child: IndexedStack(
              index: index,
              children: <Widget>[
                SignupInfo(
                  isGoogleLoading: isGoogleLoading,
                  onGoogleSignIn: signInWithGoogle,
                  setPage: (target) => setState(() {
                    index = target;
                  }),
                  nameController: nameController,
                  nameFocus: nameFocus,
                  usernameFocus: usernameFocus,
                  usernameController: usernameController,
                  monthFocus: monthFocus,
                  dayFocus: dayFocus,
                  yearFocus: yearFocus,
                  monthController: monthController,
                  dayController: dayController,
                  yearController: yearController,
                  keyFocus: keyFocus,
                  emailController: emailController,
                  emailFocus: emailFocus,
                ),
                GetPassword(
                  isGoogleLoading: isGoogleLoading,
                  onGoogleSignIn: signInWithGoogle,
                  setPage: (target) => setState(() {
                    index = target;
                  }),
                  passwordController: passwordController,
                  confirmPasswordController: confirmPasswordController,
                  passwordFocus: passwordFocus,
                  confirmPasswordFocus: confirmPasswordFocus,
                  signUp: signUp,
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

class SignupInfo extends StatefulWidget {
  final TextEditingController nameController;
  //invalid
  final FocusNode nameFocus;
  final TextEditingController usernameController;
  final FocusNode usernameFocus;
  final FocusNode monthFocus;
  final FocusNode dayFocus;
  final FocusNode yearFocus;
  final FocusNode emailFocus;
  final TextEditingController monthController;
  final TextEditingController dayController;
  final TextEditingController yearController;
  final TextEditingController emailController;
  final FocusNode keyFocus;
  final void Function(int) setPage;
  final Future<void> Function() onGoogleSignIn;
  final bool isGoogleLoading;

  const SignupInfo({
    super.key,
    required this.setPage,
    required this.nameFocus,
    required this.emailController,
    required this.emailFocus,
    required this.nameController,
    required this.usernameFocus,
    required this.usernameController,
    required this.monthFocus,
    required this.dayFocus,
    required this.yearFocus,
    required this.monthController,
    required this.dayController,
    required this.keyFocus,
    required this.yearController,
    required this.onGoogleSignIn,
    required this.isGoogleLoading,
  });

  @override
  State<SignupInfo> createState() => _SignupInfoState();
}

class _SignupInfoState extends State<SignupInfo> {
  bool usernameValid = false;
  void onKey(KeyEvent event) {
    if (widget.monthFocus.hasFocus) {
      if (widget.monthController.text.length == 2 &&
          event.logicalKey.keyLabel != 'Backspace') {
        widget.dayFocus.requestFocus();
        widget.dayController.text = event.character ?? '';
      }
    } else if (widget.dayFocus.hasFocus) {
      if (widget.dayController.text.length == 2 &&
          event.logicalKey.keyLabel != 'Backspace') {
        widget.yearFocus.requestFocus();
        widget.yearController.text = event.character ?? '';
      } else if (event.logicalKey.keyLabel == 'Backspace' &&
          widget.dayController.text.isEmpty) {
        widget.monthFocus.requestFocus();
      }
    } else if (widget.yearFocus.hasFocus) {
      if (event.logicalKey.keyLabel == 'Backspace' &&
          widget.yearController.text.isEmpty) {
        //invalid
        widget.dayFocus.requestFocus();
      }
    }
  }

  void formatTime(DateTime? birthday) {
    if (birthday != null) {
      final birthdyString = DateFormat('MM/dd/yyyy').format(birthday);
      final birthdaylist = birthdyString.split('/');
      widget.monthController.text = birthdaylist[0];
      widget.dayController.text = birthdaylist[1];
      widget.yearController.text = birthdaylist[2];
    }
  }

  DateTime? getDateTime() {
    try {
      final day = int.tryParse(widget.dayController.text);
      final month = int.tryParse(widget.monthController.text);
      final year = int.tryParse(widget.yearController.text);

      if (day == null || month == null || year == null) {
        // Invalid numeric values, return null
        return null;
      }

      if (1 > day || day > 31) {
        return null;
      }

      if (1 > month || month > 12) {
        return null;
      }

      if (1900 > year || year > DateTime.now().year) {
        return null;
      }

      // Create a DateTime object
      return DateTime(year, month, day);
    } catch (e) {
      // Parsing error, return null
      return null;
    }
  }

  void _nextPage() {
    final birthday = getDateTime();
    if (birthday != null) {
      if (birthday.compareTo(
            DateTime.now().subtract(const Duration(days: 13 * 365)),
          ) >=
          0) {
        //too young
        showSnackBar(
          text: AppLocalizations.of(context)!.tooYoungBody,
          context: context,
          variant: SnackBarVariant.destructive,
        );
        return;
      }
    } else {
      showSnackBar(
        text: AppLocalizations.of(context)!.invalidBirthdayBody,
        context: context,
        variant: SnackBarVariant.destructive,
      );
      return;
    }
    if (widget.nameController.text == '') {
      widget.nameFocus.requestFocus();
    } else if (widget.nameController.text.length > c.maxNameChars) {
      showSnackBar(
        text: AppLocalizations.of(context)!.tooManyChar,
        context: context,
        variant: SnackBarVariant.destructive,
      );
      widget.nameFocus.requestFocus();
    } else if (!usernameValid) {
      widget.usernameFocus.requestFocus();
    } else if (widget.emailController.text == '') {
      widget.emailFocus.requestFocus();
    } else {
      widget.setPage(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * c.authPaddingHorizontal,
      ),
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          SizedBox(height: height * 0.01),
          SizedBox(
            height: height * .08,
            child: Align(
              child: Text(
                l10n.createAnAccount,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const AuthDivider(indent: 20, endIndent: 20),
          SizedBox(height: height * 0.02),
          CustomInputField(
            autofillHints: [AutofillHints.name],
            focus: widget.nameFocus,
            label: l10n.name,
            controller: widget.nameController,
            inputType: TextInputType.text,
          ),
          CustomInputField(
            autofillHints: [AutofillHints.username],
            focus: widget.usernameFocus,
            label: l10n.userName,
            controller: widget.usernameController,
            inputType: TextInputType.text,
          ),
          UsernameCheckDisplay(
            controller: widget.usernameController,
            focus: widget.usernameFocus,
            onValidate: (val) {
              usernameValid = val;
            },
          ),
          const SizedBox(height: c.authElementSpacing),
          CustomInputField(
            autofillHints: [AutofillHints.email],
            label: l10n.email,
            focus: widget.emailFocus,
            controller: widget.emailController,
            inputType: TextInputType.emailAddress,
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
            focusNode: widget.keyFocus,
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
                      focus: widget.monthFocus,
                      controller: widget.monthController,
                      inputType: TextInputType.number,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.03),
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
                        focus: widget.dayFocus,
                        controller: widget.dayController,
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
                      focus: widget.yearFocus,
                      controller: widget.yearController,
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
                            initialEntryMode: DatePickerEntryMode.calendarOnly,
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
          SizedBox(height: height * 0.03),
          AuthButton.primary(label: l10n.cont, onPressed: _nextPage),
          const SizedBox(height: c.authSectionSpacing),
          const AuthDivider(indent: 20, endIndent: 20),
          const SizedBox(height: c.authElementSpacing),
          GoogleSignInButton(
            onPressed: widget.onGoogleSignIn,
            isLoading: widget.isGoogleLoading,
          ),
        ],
      ),
    );
  }
}

class GetPassword extends StatefulWidget {
  final void Function(int) setPage;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode passwordFocus;
  final FocusNode confirmPasswordFocus;
  final Future<bool> Function() signUp;
  final Future<void> Function() onGoogleSignIn;
  final bool isGoogleLoading;
  const GetPassword({
    super.key,
    required this.setPage,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.passwordFocus,
    required this.signUp,
    required this.confirmPasswordFocus,
    required this.onGoogleSignIn,
    required this.isGoogleLoading,
  });

  @override
  State<GetPassword> createState() => _GetPasswordState();
}

class _GetPasswordState extends State<GetPassword> {
  bool isLoading = false;
  bool requirePasswordMatch = true;
  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * c.authPaddingHorizontal,
      ),
      child: Center(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            SizedBox(height: height * .1),
            SizedBox(height: height * .06),
            Align(
              child: Text(
                l10n.createAPassword,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const AuthDivider(indent: 20, endIndent: 20),
            SizedBox(height: height * 0.03),
            CreatePassword(
              passwordController: widget.passwordController,
              confirmPasswordController: widget.confirmPasswordController,
              passwordFocus: widget.passwordFocus,
              confirmPasswordFocus: widget.confirmPasswordFocus,
              onRequirePasswordMatchChanged: (requireMatch) {
                requirePasswordMatch = requireMatch;
              },
            ),
            SizedBox(height: height * 0.06),
            AuthButton.primary(
              label: l10n.cont,
              isLoading: isLoading,
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!isValidSimplePassword(
                        widget.passwordController.text,
                        widget.confirmPasswordController.text,
                        requireMatch: requirePasswordMatch,
                      )) {
                        _showWeakPassword(context);
                        return;
                      }
                      setState(() => isLoading = true);
                      try {
                        await widget.signUp();
                      } finally {
                        if (mounted) setState(() => isLoading = false);
                      }
                    },
            ),
            const SizedBox(height: c.authElementSpacing),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: l10n.bySigningUp,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: l10n.termsAndConditions,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surfaceTint,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        var url = Uri.parse(c.termsUrl);
                        await launchUrl(url);
                      },
                  ),
                ],
              ),
            ),
            const SizedBox(height: c.authSectionSpacing),
            const AuthDivider(indent: 20, endIndent: 20),
            const SizedBox(height: c.authElementSpacing),
            GoogleSignInButton(
              onPressed: widget.onGoogleSignIn,
              isLoading: widget.isGoogleLoading,
            ),
          ],
        ),
      ),
    );
  }
}
