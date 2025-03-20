import 'package:flutter/material.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import '../controllers/login_controller.dart';
import '../custom_widgets/login_text_feild.dart';
import 'package:provider/provider.dart';
import '../utilities/constants.dart' as c;
import '../custom_widgets/get_app_fab.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;

    return ChangeNotifierProvider(
      create: (context) => LoginController(context: context),
      builder: (context, child) {
        return GestureDetector(
          onTap: () => Provider.of<LoginController>(context, listen: false)
              .hideKeyboard(),
          child: Scaffold(
            floatingActionButton: getAppFabBuilder(),
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
                        Consumer<LoginController>(
                          builder: (context, signUpController, _) => Text(
                            AppLocalizations.of(context)!.previous,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        )
                      ],
                    ),
                    onPressed: () =>
                        Provider.of<LoginController>(context, listen: false)
                            .previousPressed(),
                  ),
                  SizedBox(
                    height: height * .055,
                  ),
                  SizedBox(
                    height: height * .25,
                    width: width * 0.7,
                    child: Image.asset(
                        (Theme.of(context).brightness == Brightness.light)
                            ? 'images/eko_logo_light.png'
                            : 'images/eko_logo.png'),
                  ),
                  SizedBox(height: height * .05),
                  CustomInputFeild(
                    focus: Provider.of<LoginController>(context, listen: false)
                        .emailFocus,
                    label: AppLocalizations.of(context)!.email,
                    controller:
                        Provider.of<LoginController>(context, listen: false)
                            .emailController,
                    inputType: TextInputType.emailAddress,
                  ),
                  CustomInputFeild(
                    textInputAction: TextInputAction.go,
                    onEditingComplete: () =>
                        Provider.of<LoginController>(context, listen: false)
                            .logInPressed(),
                    focus: Provider.of<LoginController>(context, listen: false)
                        .passwordFocus,
                    label: AppLocalizations.of(context)!.password,
                    controller:
                        Provider.of<LoginController>(context, listen: false)
                            .passwordController,
                    inputType: TextInputType.visiblePassword,
                    password: true,
                  ),
                  SizedBox(height: height * 0.015),
                  SizedBox(
                    width: width * 0.9,
                    height: width * 0.15,
                    child: TextButton(
                        onPressed: () =>
                            Provider.of<LoginController>(context, listen: false)
                                .logInPressed(),
                        style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(.55)),
                        child: Consumer<LoginController>(
                          builder: (context, loginController, _) =>
                              loginController.loggingIn
                                  ? const CircularProgressIndicator()
                                  : Text(
                                      AppLocalizations.of(context)!.logIn,
                                      style: TextStyle(
                                        fontSize: 18,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.normal,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                        )),
                  ),
                  SizedBox(
                    width: width * 0.9,
                    height: width * 0.1,
                    child: TextButton(
                      onPressed: () =>
                          Provider.of<LoginController>(context, listen: false)
                              .forgotPasswordPressed(
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
      },
    );
  }
}
