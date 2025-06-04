import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/login_text_feild.dart';
import 'package:untitled_app/custom_widgets/warning_dialog.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/providers/auth_provider.dart';
import 'package:untitled_app/utilities/constants.dart' as c;

class ReAuthPage extends ConsumerStatefulWidget {
  const ReAuthPage({super.key});

  @override
  ConsumerState<ReAuthPage> createState() => _ReAuthPageState();
}

class _ReAuthPageState extends ConsumerState<ReAuthPage> {
  final passwordController = TextEditingController();
  final passwordFocus = FocusNode();
  bool isLoading = false;

  @override
  void dispose() {
    passwordController.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  int handleError(String errorCode) {
    switch (errorCode) {
      case 'success':
        return 0;
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

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          AppLocalizations.of(context)!.deleteAccount,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        // =mainAxisSize: MainAxisSize.min,

        children: [
          SizedBox(
            height: width * 0.05,
          ),
          SizedBox(
              width: width * 0.7,
              child: Text(
                  AppLocalizations.of(context)!.deleteAcountReAuthWarning,
                  textAlign: TextAlign.center)),
          SizedBox(
            height: width * 0.2,
          ),
          CustomInputField(
            textInputAction: TextInputAction.go,
            // onEditingComplete: () =>
            //     prov.Provider.of<LoginController>(context, listen: false)
            //         .logInPressed(),
            focus: passwordFocus,
            label: AppLocalizations.of(context)!.password,
            controller: passwordController,
            inputType: TextInputType.visiblePassword,
            password: true,
          ),
          SizedBox(
            height: width * 0.05,
          ),
          InkWell(
            child: Container(
              alignment: Alignment.center,
              height: width * 0.15,
              width: width * 0.9,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: Theme.of(context).colorScheme.primary),
              child: Text(AppLocalizations.of(context)!.deleteAccount,
                  style: TextStyle(
                      fontSize: width * 0.06,
                      color: Theme.of(context).colorScheme.onPrimary),
                  textAlign: TextAlign.center),
            ),
            onTap: () async {
              if (!isLoading) {
                setState(() {
                  isLoading = true;
                });
                final password = passwordController.text;
                if (password == '') {
                  passwordFocus.requestFocus();
                } else {
                  if (handleError((await ref.read(authProvider.notifier).signIn(
                          password: password,
                          email: ref.read(authProvider).email!))) ==
                      0) {
                    await ref.read(authProvider.notifier).deleteAccount();
                  }
                }
                setState(() {
                  isLoading = false;
                });
              }
            },
          ),
          SizedBox(height: width * 0.05)
        ],
      )),
    );
  }
}
