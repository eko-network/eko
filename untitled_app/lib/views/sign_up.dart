import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as prov;
import 'package:untitled_app/controllers/sign_up_controller.dart';
import 'package:untitled_app/custom_widgets/warning_dialog.dart';
import 'package:untitled_app/interfaces/user.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../custom_widgets/login_text_feild.dart';
import '../utilities/constants.dart' as c;
import '../custom_widgets/download_button_if_web.dart';

class _BackButton extends StatelessWidget {
  final PageController pageController;
  const _BackButton({required this.pageController});

  @override
  Widget build(BuildContext context) {
    return IconButton(
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
      onPressed: () async {
        if (pageController.page != 0.0) {
          await pageController.previousPage(
              duration: const Duration(milliseconds: c.signUpAnimationDuration),
              curve: Curves.decelerate);
        } else {
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
      },
    );
  }
}

class SignUp extends ConsumerStatefulWidget {
  const SignUp({super.key});

  @override
  ConsumerState<SignUp> createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignUp> {
  final pageController = PageController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final nameController = TextEditingController();
  final passwordFocus = FocusNode();
  final usernameFocus = FocusNode();

  bool isLoading = false;
  bool goodPassword = false;

  @override
  void dispose() {
    pageController.dispose();
    pageController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    emailController.dispose();
    usernameController.dispose();
    usernameFocus.dispose();
    nameController.dispose();
    passwordFocus.dispose();
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
              () async {
                context.pop();

                if (pageController.page != 0.0) {
                  await pageController.previousPage(
                      duration: const Duration(
                          milliseconds: c.signUpAnimationDuration),
                      curve: Curves.decelerate);
                } else {
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
        showMyDialog(
            AppLocalizations.of(context)!.weakPasswordTitle,
            AppLocalizations.of(context)!.weakPasswordBody,
            [AppLocalizations.of(context)!.tryAgain],
            [context.pop],
            context);
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

  void signUpPressed() async {
    if (passwordController.text == '') {
      passwordFocus.requestFocus();
    } else {
      if (goodPassword ||
          (passwordController.text == 'password' && kDebugMode)) {
        setState(() {
          isLoading = true;
        });
        if (await isUsernameAvailable(usernameController.text.trim())) {
          if (_handleError(await ref.read(authProvider.notifier).signUp(
              email: emailController.text.trim(),
              password: passwordController.text))) {
                //FIXME SIGNUP BROKEN
            // locator<CurrentUser>().addUserDataToFirestore();
          }
        } else {
          _handleError('username-taken');
        }
        setState(() {
          isLoading = true;
        });
      } else {
        _handleError('weak-password');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return prov.ChangeNotifierProvider(
      create: (context) => SignUpController(context: context),
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            floatingActionButton: downloadButtonIfWeb(),
            body: Center(
              child: SizedBox(
                width: c.widthGetter(context),
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller:
                      prov.Provider.of<SignUpController>(context, listen: false)
                          .pageController,
                  children: <Widget>[
                    GetInfo(
                      pageController: pageController,
                    ),
                    GetPassword(
                      pageController: pageController,
                    ),
                    Placeholder(), //FIXME for some reson this stops everything from breaking
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class GetInfo extends StatelessWidget {
  final PageController pageController;
  const GetInfo({super.key, required this.pageController});

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
            _BackButton(
              pageController: pageController,
            ),
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
                )),
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
            CustomInputFeild(
              focus: prov.Provider.of<SignUpController>(context, listen: false)
                  .nameFocus,
              label: AppLocalizations.of(context)!.name,
              controller:
                  prov.Provider.of<SignUpController>(context, listen: false)
                      .nameController,
              inputType: TextInputType.text,
              // maxLen: c.maxNameChars,
            ),
            // SizedBox(height: height * c.loginPadding),
            CustomInputFeild(
              onChanged: (s) =>
                  prov.Provider.of<SignUpController>(context, listen: false)
                      .onUsernameChanged(s),
              focus: prov.Provider.of<SignUpController>(context, listen: false)
                  .usernameFocus,
              label: AppLocalizations.of(context)!.userName,
              controller:
                  prov.Provider.of<SignUpController>(context, listen: false)
                      .usernameController,
              inputType: TextInputType.text,
              // maxLen: c.maxUsernameChars,
            ),
            if (prov.Provider.of<SignUpController>(context, listen: true)
                    .usernameController
                    .text !=
                '')
              Row(
                children: [
                  const SizedBox(width: 5),
                  prov.Consumer<SignUpController>(
                    builder: (context, signUpController, _) => signUpController
                            .validUsername
                        ? signUpController.isChecking
                            ? Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  width: width * 0.05,
                                  height: width * 0.05,
                                  child: const CircularProgressIndicator(),
                                ))
                            : signUpController.availableUsername
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(
                                      AppLocalizations.of(context)!.available,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .usernameInUse,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error),
                                    ),
                                  )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            //crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.invalidUserName,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.error),
                              ),
                              InkWell(
                                  onTap: () {
                                    prov.Provider.of<SignUpController>(context,
                                            listen: false)
                                        .showUserNameReqs();
                                  },
                                  child: Icon(
                                    Icons.help_outline_outlined,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ))
                            ],
                          ),
                  )
                ],
              ),
            SizedBox(height: height * c.loginPadding),
            CustomInputFeild(
              label: AppLocalizations.of(context)!.email,
              focus: prov.Provider.of<SignUpController>(context, listen: false)
                  .emailFocus,
              controller:
                  prov.Provider.of<SignUpController>(context, listen: false)
                      .emailController,
              inputType: TextInputType.emailAddress,
            ),

            Text(
              AppLocalizations.of(context)!.birthday,
              style: const TextStyle(
                  fontSize: 18, decoration: TextDecoration.underline),
            ),
            RawKeyboardListener(
                onKey:
                    prov.Provider.of<SignUpController>(context, listen: false)
                        .onKey,
                focusNode:
                    prov.Provider.of<SignUpController>(context, listen: false)
                        .keyFocus,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.month),
                        CustomInputFeild(
                          filter: r'[0-9]*',
                          showCounter: false,
                          maxLen: 2,
                          padding: false,
                          width: width * 0.15,
                          focus: prov.Provider.of<SignUpController>(context,
                                  listen: false)
                              .monthFocus,
                          controller: prov.Provider.of<SignUpController>(
                                  context,
                                  listen: false)
                              .monthController,
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
                          CustomInputFeild(
                            filter: r'[0-9]*',
                            showCounter: false,
                            maxLen: 2,
                            padding: false,
                            width: width * 0.15,
                            focus: prov.Provider.of<SignUpController>(context,
                                    listen: false)
                                .dayFocus,
                            controller: prov.Provider.of<SignUpController>(
                                    context,
                                    listen: false)
                                .dayController,
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
                        CustomInputFeild(
                          filter: r'[0-9]*',
                          showCounter: false,
                          maxLen: 4,
                          padding: false,
                          width: width * 0.3,
                          focus: prov.Provider.of<SignUpController>(context,
                                  listen: false)
                              .yearFocus,
                          controller: prov.Provider.of<SignUpController>(
                                  context,
                                  listen: false)
                              .yearController,
                          inputType: TextInputType.number,
                        ),
                      ],
                    ),
                    const SizedBox(width: 5),
                    Column(children: [
                      const Text(''),
                      IconButton(
                        onPressed: () async {
                          prov.Provider.of<SignUpController>(context,
                                  listen: false)
                              .formatTime(
                            await showDatePicker(
                              context: context,
                              initialEntryMode:
                                  DatePickerEntryMode.calendarOnly,
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            ),
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
                onPressed: () =>
                    prov.Provider.of<SignUpController>(context, listen: false)
                        .forwardPressed(),
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
      ),
    ));
  }
}

class GetPassword extends StatelessWidget {
  final PageController pageController;
  const GetPassword({super.key, required this.pageController});

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
            _BackButton(
              pageController: pageController,
            ),
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
            CustomInputFeild(
              onChanged: (s) =>
                  prov.Provider.of<SignUpController>(context, listen: false)
                      .passwordChanged(),
              onEditingComplete: () =>
                  prov.Provider.of<SignUpController>(context, listen: false)
                      .passwordConfirmFocus
                      .requestFocus(),
              label: AppLocalizations.of(context)!.password,
              focus: prov.Provider.of<SignUpController>(context, listen: false)
                  .passwordFocus,
              controller:
                  prov.Provider.of<SignUpController>(context, listen: false)
                      .passwordController,
              inputType: TextInputType.visiblePassword,
              password: true,
            ),
            SizedBox(height: height * c.loginPadding),
            CustomInputFeild(
              onChanged: (s) =>
                  prov.Provider.of<SignUpController>(context, listen: false)
                      .passwordChanged(),
              onEditingComplete: () =>
                  prov.Provider.of<SignUpController>(context, listen: false)
                      .signUpPressed(),
              textInputAction: TextInputAction.done,
              label: AppLocalizations.of(context)!.confirmPassword,
              focus: prov.Provider.of<SignUpController>(context, listen: false)
                  .passwordConfirmFocus,
              controller:
                  prov.Provider.of<SignUpController>(context, listen: false)
                      .passwordConfirmController,
              inputType: TextInputType.visiblePassword,
              password: true,
            ),
            SizedBox(height: height * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: height * c.loginPadding,
              ),
              child: LinearProgressIndicator(
                minHeight: 12,
                value: prov.Provider.of<SignUpController>(context, listen: true)
                    .passwordPercent,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: prov.Consumer<SignUpController>(
                builder: (context, signUpController, _) => Text(
                  '${signUpController.passed[0]}${AppLocalizations.of(context)!.passwordLen}\n'
                  '${signUpController.passed[1]}${AppLocalizations.of(context)!.passwordLower}\n'
                  '${signUpController.passed[2]}${AppLocalizations.of(context)!.passwordUpper}\n'
                  '${signUpController.passed[3]}${AppLocalizations.of(context)!.passwordNumber}\n'
                  '${signUpController.passed[4]}${AppLocalizations.of(context)!.passwordSpecial}\n'
                  '${signUpController.passed[5]}${AppLocalizations.of(context)!.passwordMatch}\n',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            //const Spacer(),
            SizedBox(
              height: height * 0.1,
            ),
            SizedBox(
              width: width * 0.9,
              height: width * 0.15,
              child: TextButton(
                onPressed: () =>
                    prov.Provider.of<SignUpController>(context, listen: false)
                        .signUpPressed(),
                style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary),
                child: prov.Provider.of<SignUpController>(context, listen: true)
                        .loggingIn
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
