import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:untitled_app/custom_widgets/error_snack_bar.dart';
import 'package:untitled_app/custom_widgets/warning_dialog.dart';
import 'package:untitled_app/interfaces/user.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/providers/auth_provider.dart';
import 'package:untitled_app/providers/nav_bar_provider.dart';
import 'package:untitled_app/providers/theme_provider.dart';
import 'package:untitled_app/widgets/create_password.dart';
import 'package:untitled_app/widgets/username_check_display.dart';
import 'package:url_launcher/url_launcher.dart';
import '../custom_widgets/login_text_feild.dart';
import '../utilities/constants.dart' as c;
import '../custom_widgets/download_button_if_web.dart';

void _showWeakPassword(BuildContext context) {
  showMyDialog(
      AppLocalizations.of(context)!.weakPasswordTitle,
      AppLocalizations.of(context)!.weakPasswordBody,
      [AppLocalizations.of(context)!.tryAgain],
      [context.pop],
      context);
}

void _showConfirmExit(BuildContext context) {
  showMyDialog(
      AppLocalizations.of(context)!.exitCreateAccountTitle,
      AppLocalizations.of(context)!.exitCreateAccountBody,
      [
        AppLocalizations.of(context)!.goBack,
        AppLocalizations.of(context)!.stay
      ],
      [
        () {
          context.pop();
          context.go('/');
        },
        context.pop
      ],
      context);
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
    monthFocus.dispose;
    dayFocus.dispose;
    yearFocus.dispose();
    monthController.dispose;
    dayController.dispose;
    yearController.dispose();
    keyFocus.dispose();
    super.dispose();
  }

  bool _handleError(String errorCode) {
    switch (errorCode) {
      case 'success':
        return true;
      case 'username-taken':
        showMyDialog(
            AppLocalizations.of(context)!.usernameTakenTitle,
            AppLocalizations.of(context)!.usernameTakenBody,
            [AppLocalizations.of(context)!.goBack],
            [
              () {
                context.pop();
                usernameController.clear();
                setState(() {
                  index = 0;
                });
                usernameFocus.requestFocus();
              }
            ],
            context);
        break;
      case 'invalid-email':
        showMyDialog(
            AppLocalizations.of(context)!.invalidEmailTittle,
            AppLocalizations.of(context)!.invalidEmailBody,
            [AppLocalizations.of(context)!.tryAgain],
            [context.pop],
            context);
        break;
      case 'weak-password':
        _showWeakPassword(context);
        break;
      case 'email-already-in-use':
        showMyDialog(
            AppLocalizations.of(context)!.emailAlreadyInUseTitle,
            AppLocalizations.of(context)!.emailAlreadyInUseBody,
            [
              AppLocalizations.of(context)!.logIn,
              AppLocalizations.of(context)!.tryAgain
            ],
            [
//invalid
              () {
                context.pop();
                context.go('/');
              },
              context.pop
            ],
            context);
        break;
      default:
        showMyDialog(
            AppLocalizations.of(context)!.defaultErrorTittle,
            AppLocalizations.of(context)!.defaultErrorBody,
            [AppLocalizations.of(context)!.tryAgain],
            [context.pop],
            context);
        break;
    }
    return false;
  }

  Future<bool> signUp() async {
    //make sure this is true since user could be coming from settings
    ref.read(navBarProvider.notifier).enable();
    if (await isUsernameAvailable(usernameController.text.trim())) {
      if (_handleError(await ref.read(authProvider.notifier).signUp(
          email: emailController.text.trim(),
          password: passwordController.text,
          username: usernameController.text.trim(),
          name: nameController.text,
          birthday:
              '${monthController.text}/${dayController.text}/${yearController.text}'))) {
        return true;
      }
    } else {
      _handleError('username-taken');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            _showConfirmExit(context);
          },
          child: Scaffold(
            floatingActionButton: downloadButtonIfWeb(),
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      if (index == 1) {
                        setState(() {
                          index = 0;
                        });
                        return;
                      }
                      _showConfirmExit(context);
                    },
                    icon: Row(
                      children: [
                        Icon(Icons.arrow_back_ios_rounded,
                            color: Theme.of(context).colorScheme.onSurface),
                        Text(
                          AppLocalizations.of(context)!.previous,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
            body: Center(
              child: SizedBox(
                width: c.widthGetter(context),
                child: IndexedStack(
                  index: index,
                  children: <Widget>[
                    GetInfo(
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
                      setPage: (target) => setState(() {
                        index = target;
                      }),
                      passwordController: passwordController,
                      confirmPasswordController: confirmPasswordController,
                      passwordFocus: passwordFocus,
                      confirmPasswordFocus: confirmPasswordFocus,
                      signUp: signUp,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

class GetInfo extends StatefulWidget {
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

  const GetInfo(
      {super.key,
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
      required this.yearController});

  @override
  State<GetInfo> createState() => _GetInfoState();
}

class _GetInfoState extends State<GetInfo> {
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
              DateTime.now().subtract(const Duration(days: 13 * 365))) >=
          0) {
        //too young
        showMyDialog(
            AppLocalizations.of(context)!.tooYoungTitle,
            AppLocalizations.of(context)!.tooYoungBody,
            [AppLocalizations.of(context)!.ok],
            [
              () {
                context.pop();
              }
            ],
            context);
        return;
      }
    } else {
      showMyDialog(
          AppLocalizations.of(context)!.invalidBirthdayTitle,
          AppLocalizations.of(context)!.invalidBirthdayBody,
          [AppLocalizations.of(context)!.ok],
          [
            () {
              context.pop();
            }
          ],
          context);
      return;
    }
    if (widget.nameController.text == '') {
      widget.nameFocus.requestFocus();
    } else if (widget.nameController.text.length > c.maxNameChars) {
      showSnackBar(
          text: AppLocalizations.of(context)!.tooManyChar, context: context);
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          SizedBox(
            height: height * 0.02,
          ),
          SizedBox(
            height: height * .1,
            child: Align(
              child: Text(AppLocalizations.of(context)!.createAnAccount,
                  style: TextStyle(
                      fontSize: 35,
                      color: Theme.of(context).colorScheme.onSurface)),
            ),
          ),
          Divider(
            height: 0,
            thickness: height * 0.002,
            indent: width * 0.07,
            endIndent: width * 0.07,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          SizedBox(
            height: height * 0.03,
          ),
          CustomInputField(
            autofillHints: [AutofillHints.name],
            focus: widget.nameFocus,
            label: AppLocalizations.of(context)!.name,
            controller: widget.nameController,
            inputType: TextInputType.text,
            // maxLen: c.maxNameChars,
          ),
          // SizedBox(height: height * c.loginPadding),
          CustomInputField(
            autofillHints: [AutofillHints.username],
            focus: widget.usernameFocus,
            label: AppLocalizations.of(context)!.userName,
            controller: widget.usernameController,
            inputType: TextInputType.text,
            // maxLen: c.maxUsernameChars,
          ),
          UsernameCheckDisplay(
            controller: widget.usernameController,
            focus: widget.usernameFocus,
            onValidate: (val) {
              usernameValid = val;
            },
          ),
          SizedBox(height: height * c.loginPadding),
          CustomInputField(
            autofillHints: [AutofillHints.email],
            label: AppLocalizations.of(context)!.email,
            focus: widget.emailFocus,
            controller: widget.emailController,
            inputType: TextInputType.emailAddress,
          ),

          Text(
            AppLocalizations.of(context)!.birthday,
            style: const TextStyle(
                fontSize: 18, decoration: TextDecoration.underline),
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
                      Text(AppLocalizations.of(context)!.month),
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
                        Text(AppLocalizations.of(context)!.day),
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
                        )
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.year),
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
                  Column(children: [
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
                          //_getPageData(page);
                          //_setPageData(page + 1);
                        );
                      },
                      icon: const Icon(CupertinoIcons.calendar),
                      iconSize: 35,
                    )
                  ])
                ],
              )),
          Text(
            AppLocalizations.of(context)!.birthdayExplanation,
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          SizedBox(
            height: height * 0.08,
          ),
          SizedBox(
            width: width * 0.9,
            height: width * 0.15,
            child: TextButton(
              onPressed: () => _nextPage(),
              style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary),
              child: Text(
                AppLocalizations.of(context)!.cont,
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 1,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
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
  const GetPassword(
      {super.key,
      required this.setPage,
      required this.passwordController,
      required this.confirmPasswordController,
      required this.passwordFocus,
      required this.signUp,
      required this.confirmPasswordFocus});

  @override
  State<GetPassword> createState() => _GetPasswordState();
}

class _GetPasswordState extends State<GetPassword> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: Center(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            SizedBox(
                height: height * .1,
                child: Align(
                  child: Text(AppLocalizations.of(context)!.createAPassword,
                      style: TextStyle(
                          fontSize: 35,
                          color: Theme.of(context).colorScheme.onSurface)),
                )),
            Divider(
              height: 0,
              thickness: height * 0.002,
              indent: width * 0.07,
              endIndent: width * 0.07,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            SizedBox(height: height * 0.04),
            CreatePassword(
              passwordController: widget.passwordController,
              confirmPasswordController: widget.confirmPasswordController,
              passwordFocus: widget.passwordFocus,
              confirmPasswordFocus: widget.confirmPasswordFocus,
            ),
            SizedBox(
              height: height * 0.1,
            ),
            SizedBox(
              width: width * 0.9,
              height: width * 0.15,
              child: TextButton(
                onPressed: () async {
                  if (!isValidPassword(widget.passwordController.text,
                      widget.confirmPasswordController.text)) {
                    _showWeakPassword(context);
                    return;
                  }
                  if (isLoading) return;
                  setState(() {
                    isLoading = true;
                  });
                  if (!(await widget.signUp())) {
                    //only unlock the button if signup fails
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary),
                child: isLoading
                    ? CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : Text(
                        AppLocalizations.of(context)!.cont,
                        style: TextStyle(
                          fontSize: 18,
                          letterSpacing: 1,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
              ),
            ),
            SizedBox(height: height * 0.008),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: AppLocalizations.of(context)!.bySigningUp,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: AppLocalizations.of(context)!.termsAndConditions,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.surfaceTint),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        var url = Uri.parse(c.termsUrl);
                        await launchUrl(url);
                      },
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.03),
          ],
        ),
      ),
    ));
  }
}
