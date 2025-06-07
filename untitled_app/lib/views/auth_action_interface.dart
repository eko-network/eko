import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/interfaces/user.dart';
import 'package:untitled_app/widgets/create_password.dart';
import 'package:untitled_app/widgets/loading_spinner.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import '../custom_widgets/warning_dialog.dart';
import '../utilities/constants.dart' as c;

//Forgot password page

class AuthActionInterface extends StatefulWidget {
  final Map<String, String> urlData;
  const AuthActionInterface({super.key, required this.urlData});

  @override
  State<AuthActionInterface> createState() => _AuthActionInterfaceState();
}

class _AuthActionInterfaceState extends State<AuthActionInterface> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();
  String email = '';

  bool isLoading = false;

  void showExitWarning() {
    showMyDialog(
        AppLocalizations.of(context)!.exitEditProfileTitle,
        '',
        [
          AppLocalizations.of(context)!.exit,
          AppLocalizations.of(context)!.stay
        ],
        [
          () {
            context.pop();
            context.pop();
          },
          context.pop
        ],
        context);
  }

  Future<void> setPasswordPressed() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (passwordController.text == '') {
      passwordFocus.requestFocus();
    } else {
      if (isValidPassword(
          passwordController.text, confirmPasswordController.text)) {
        setState(() {
          isLoading = true;
        });
        if ((await resetPassword(
                widget.urlData['oobCode'] ?? '', passwordController.text)) ==
            'success') {
          if (mounted) {
            showMyDialog(
                AppLocalizations.of(context)!.passwordResetTitle,
                AppLocalizations.of(context)!.passwordResetBody,
                [AppLocalizations.of(context)!.ok],
                [
                  () {
                    context.pop();
                    context.go('/login');
                  }
                ],
                context);
          }
        } else {
          passwordController.text = '';
          confirmPasswordController.text = '';
          setState(() {
            index = 1;
          });
        }

        setState(() {
          isLoading = true;
        });
      } else {
        showMyDialog(
            AppLocalizations.of(context)!.weakPasswordTitle,
            AppLocalizations.of(context)!.weakPasswordBody,
            [AppLocalizations.of(context)!.tryAgain],
            [context.pop],
            context);
      }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if ((widget.urlData['mode'] ?? '') == 'resetPassword') {
        try {
          final userEmail =
              await verifyPasswordReset(widget.urlData['oobCode'] ?? '');
          setState(() {
            email = userEmail;
            index = 2;
          });
        } on FirebaseAuthException {
          setState(() {
            index = 1;
          });
        }
      } else {
        setState(() {
          index = 1;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordFocus.dispose();
    confirmPasswordController.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  int index = 0;
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = c.widthGetter(context);
    return PopScope(
      canPop: index == 1,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (index == 2) {
          showExitWarning();
        }
      },
      child: Center(
        child: SizedBox(
          width: width,
          child: IndexedStack(
            index: index,
            children: <Widget>[
              Center(child: LoadingSpinner()),
              Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: width * 0.8,
                        child: Text(
                          AppLocalizations.of(context)!.badAuthState,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/'),
                        style: TextButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary),
                        child: Text(
                          AppLocalizations.of(context)!.exit,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Scaffold(
                body: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: Center(
                    child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      children: [
                        SizedBox(
                          height: height * 0.03,
                        ),
                        Text(
                          '${AppLocalizations.of(context)!.resetPasswordPromt} $email',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 20),
                        ),
                        SizedBox(height: height * c.loginPadding),
                        CreatePassword(
                          passwordController: passwordController,
                          confirmPasswordController: confirmPasswordController,
                          passwordFocus: passwordFocus,
                          confirmPasswordFocus: confirmPasswordFocus,
                        ),
                        SizedBox(
                          height: height * 0.05,
                        ),
                        SizedBox(
                          width: width * 0.9,
                          height: width * 0.15,
                          child: TextButton(
                            onPressed: () => setPasswordPressed(),
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary),
                            child: isLoading
                                ? CircularProgressIndicator(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  )
                                : Text(
                                    AppLocalizations.of(context)!.setPassword,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 18,
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.normal,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                          ),
                        ),
                        TextButton(
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 18),
                          ),
                          onPressed: () => showExitWarning(),
                        ),
                        SizedBox(height: height * 0.03),
                      ],
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
