import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/download_button_if_web.dart';
import 'package:untitled_app/custom_widgets/warning_dialog.dart';
import 'package:untitled_app/interfaces/user.dart' as user;
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/providers/auth_provider.dart';
import 'package:untitled_app/widgets/icons.dart';
import '../custom_widgets/login_text_feild.dart';
import '../utilities/constants.dart' as c;

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

  @override
  void dispose() {
    emailFocus.dispose();
    passwordFocus.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  int handleError(String errorCode) {
    switch (errorCode) {
      case 'success':
        return 0;
      case 'invalid-email':
        showMyDialog(
            AppLocalizations.of(context)!.invalidEmailTittle,
            AppLocalizations.of(context)!.invalidEmailBody,
            [AppLocalizations.of(context)!.tryAgain],
            [context.pop],
            context);
        return 1;
      case 'user-not-found':
        showMyDialog(
            AppLocalizations.of(context)!.userNotFoundTitle,
            AppLocalizations.of(context)!.userNotFoundBody,
            [
              AppLocalizations.of(context)!.signUp,
              AppLocalizations.of(context)!.tryAgain
            ],
            [
              () {
                context.pop();
                context.go('/signup');
              },
              context.pop
            ],
            context);
        return 1;
      case 'wrong-password':
        showMyDialog(
            AppLocalizations.of(context)!.wrongPasswordTittle,
            AppLocalizations.of(context)!.wrongPasswordBody,
            [AppLocalizations.of(context)!.tryAgain],
            [context.pop],
            context);
        return 1;
      case 'user-disabled':
        showMyDialog(
            AppLocalizations.of(context)!.userDisabledTittle,
            AppLocalizations.of(context)!.userDisabledBody,
            [AppLocalizations.of(context)!.tryAgain],
            [context.pop],
            context);
        return 1;
      default:
        showMyDialog(
            AppLocalizations.of(context)!.defaultErrorTittle,
            AppLocalizations.of(context)!.defaultErrorBody,
            [AppLocalizations.of(context)!.tryAgain],
            [context.pop],
            context);
        return 1;
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
      if (handleError(await ref.read(authProvider.notifier).signIn(
              email: emailController.text.trim(),
              password: passwordController.text)) ==
          0) {}
      setState(() {
        isLoading = false;
      });
    }
  }

  void forgotPasswordPressed(String? countryCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.outlineVariant,
          title: Text(AppLocalizations.of(context)!.resetPassword),
          content: SingleChildScrollView(
            child: CustomInputField(
              label: AppLocalizations.of(context)!.email,
              controller: emailController,
              inputType: TextInputType.emailAddress,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                context.pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.sendResetLink),
              onPressed: () async {
                context.pop();
                if (handleError(await user.forgotPassword(
                        countryCode: countryCode,
                        email: emailController.text.trim())) ==
                    0) {
                  if (context.mounted) {
                    showMyDialog(
                        AppLocalizations.of(context)!.forgotPasswordTittle,
                        AppLocalizations.of(context)!.forgotPasswordBody,
                        [AppLocalizations.of(context)!.ok],
                        [context.pop],
                        context);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        floatingActionButton: downloadButtonIfWeb(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              IconButton(
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
                    )
                  ],
                ),
                onPressed: () => context.go('/'),
              ),
              SizedBox(
                height: height * .055,
              ),
              SizedBox(height: height * .25, width: width * 0.7, child: Eko()),
              SizedBox(height: height * .05),
              CustomInputField(
                focus: emailFocus,
                label: AppLocalizations.of(context)!.email,
                controller: emailController,
                inputType: TextInputType.emailAddress,
              ),
              CustomInputField(
                textInputAction: TextInputAction.go,
                onEditingComplete: () => loginPressed(),
                focus: passwordFocus,
                label: AppLocalizations.of(context)!.password,
                controller: passwordController,
                inputType: TextInputType.visiblePassword,
                password: true,
              ),
              SizedBox(height: height * 0.015),
              SizedBox(
                  width: width * 0.9,
                  height: width * 0.15,
                  child: TextButton(
                    onPressed: () => loginPressed(),
                    style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: .55)),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            AppLocalizations.of(context)!.logIn,
                            style: TextStyle(
                              fontSize: 18,
                              letterSpacing: 1,
                              fontWeight: FontWeight.normal,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                  )),
              SizedBox(
                width: width * 0.9,
                height: width * 0.1,
                child: TextButton(
                  onPressed: () => forgotPasswordPressed(
                      AppLocalizations.of(context)!.localeName),
                  child: Text(
                    AppLocalizations.of(context)!.forgotPassword,
                    style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 1,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
