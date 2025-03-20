import 'package:flutter/material.dart';
import "package:untitled_app/custom_widgets/loading_spinner.dart";
import '../custom_widgets/login_text_feild.dart';

import "package:provider/provider.dart";
import "package:untitled_app/localization/generated/app_localizations.dart";
import "../controllers/auth_action_interface_controller.dart";
import "../utilities/constants.dart" as c;

class AuthActionInterface extends StatelessWidget {
  final Map<String, String> urlData;
  const AuthActionInterface({super.key, required this.urlData});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          AuthActionInterfaceController(context: context, urlData: urlData),
      builder: (context, child) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) =>
              Provider.of<AuthActionInterfaceController>(context, listen: false)
                  .backPressed(didPop: didPop),
          child: Center(
            child: SizedBox(
              width: c.widthGetter(context),
              child: PageView(
                controller: Provider.of<AuthActionInterfaceController>(context,
                        listen: false)
                    .pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const <Widget>[
                  _LoadingPage(),
                  _InvalidPage(),
                  _ResetPasswordPage(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Center(child: LoadingSpinner());
  }
}

class _InvalidPage extends StatelessWidget {
  const _InvalidPage();

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    return Scaffold(
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
              onPressed: () => Provider.of<AuthActionInterfaceController>(
                      context,
                      listen: false)
                  .exitOnPagePressed(),
              style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary),
              child: Text(
                AppLocalizations.of(context)!.exit,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ResetPasswordPage extends StatelessWidget {
  const _ResetPasswordPage();

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
              // const _BackButton(),
              // SizedBox(
              //     height: height * .1,
              //     child: Align(
              //       child: Text(AppLocalizations.of(context)!.createAPassword,
              //           style: TextStyle(
              //               fontSize: 35,
              //               color: Theme.of(context).colorScheme.onBackground)),
              //     )),
              // Divider(
              //   height: 0,
              //   thickness: height * 0.002,
              //   indent: width * 0.07,
              //   endIndent: width * 0.07,
              //   color: Theme.of(context).colorScheme.onBackground,
              // ),
              SizedBox(
                height: height * 0.03,
              ),
              Text(
                "${AppLocalizations.of(context)!.resetPasswordPromt} ${Provider.of<AuthActionInterfaceController>(context, listen: true).userEmail}",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 20),
              ),

              SizedBox(height: height * c.loginPadding),
              CustomInputFeild(
                onChanged: (s) => Provider.of<AuthActionInterfaceController>(
                        context,
                        listen: false)
                    .passwordChanged(),
                onEditingComplete: () =>
                    Provider.of<AuthActionInterfaceController>(context,
                            listen: false)
                        .passwordConfirmFocus
                        .requestFocus(),
                label: AppLocalizations.of(context)!.password,
                focus: Provider.of<AuthActionInterfaceController>(context,
                        listen: false)
                    .passwordFocus,
                controller: Provider.of<AuthActionInterfaceController>(context,
                        listen: false)
                    .passwordController,
                inputType: TextInputType.visiblePassword,
                password: true,
              ),
              SizedBox(height: height * c.loginPadding),
              CustomInputFeild(
                onChanged: (s) => Provider.of<AuthActionInterfaceController>(
                        context,
                        listen: false)
                    .passwordChanged(),
                onEditingComplete: () =>
                    Provider.of<AuthActionInterfaceController>(context,
                            listen: false)
                        .setPasswordPressed(),
                textInputAction: TextInputAction.done,
                label: AppLocalizations.of(context)!.confirmPassword,
                focus: Provider.of<AuthActionInterfaceController>(context,
                        listen: false)
                    .passwordConfirmFocus,
                controller: Provider.of<AuthActionInterfaceController>(context,
                        listen: false)
                    .passwordConfirmController,
                inputType: TextInputType.visiblePassword,
                password: true,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: height * c.loginPadding,
                ),
                child: LinearProgressIndicator(
                  minHeight: 12,
                  value: Provider.of<AuthActionInterfaceController>(context,
                          listen: true)
                      .passwordPercent,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Consumer<AuthActionInterfaceController>(
                  builder: (context, signUpController, _) => Text(
                    "${signUpController.passed[0]}${AppLocalizations.of(context)!.passwordLen}\n"
                    "${signUpController.passed[1]}${AppLocalizations.of(context)!.passwordLower}\n"
                    "${signUpController.passed[2]}${AppLocalizations.of(context)!.passwordUpper}\n"
                    "${signUpController.passed[3]}${AppLocalizations.of(context)!.passwordNumber}\n"
                    "${signUpController.passed[4]}${AppLocalizations.of(context)!.passwordSpecial}\n"
                    "${signUpController.passed[5]}${AppLocalizations.of(context)!.passwordMatch}\n",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              //const Spacer(),
              SizedBox(
                height: height * 0.05,
              ),
              SizedBox(
                width: width * 0.9,
                height: width * 0.15,
                child: TextButton(
                  onPressed: () => Provider.of<AuthActionInterfaceController>(
                          context,
                          listen: false)
                      .setPasswordPressed(),
                  style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary),
                  child: Provider.of<AuthActionInterfaceController>(context,
                              listen: true)
                          .loggingIn
                      ? CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.onPrimary,
                        )
                      : Text(
                          AppLocalizations.of(context)!.setPassword,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            letterSpacing: 1,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.onPrimary,
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
                onPressed: () => Provider.of<AuthActionInterfaceController>(
                        context,
                        listen: false)
                    .showExitWarning(),
              ),
              SizedBox(height: height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
