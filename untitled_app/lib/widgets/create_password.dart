import 'package:flutter/material.dart';
import 'package:untitled_app/custom_widgets/login_text_feild.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/utilities/constants.dart' as c;

List<bool> _getPassedList(String pass1, String pass2) {
  final List<bool> passed = List.generate(6, (index) => false, growable: false);
  passed[0] = (pass1).length >= 7 && (pass1).length <= 32;
  passed[1] = pass1.contains(RegExp(r'[a-z]'));
  passed[2] = pass1.contains(RegExp(r'[A-Z]'));
  passed[3] = pass1.contains(RegExp(r'[0-9]'));
  passed[4] = !pass1.contains(RegExp(r'^[A-Za-z0-9]*$'));
  passed[5] = pass1 == pass2 && pass1 != '';
  return passed;
}

bool isValidPassword(String pass1, String pass2) {
  return _getPassedList(pass1, pass2).where((item) => item).length == 6;
}

class CreatePassword extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode passwordFocus;
  final FocusNode confirmPasswordFocus;
  const CreatePassword(
      {super.key,
      required this.passwordController,
      required this.confirmPasswordController,
      required this.passwordFocus,
      required this.confirmPasswordFocus});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Column(children: [
      CustomInputField(
        autofillHints: [AutofillHints.password],
        onEditingComplete: () => confirmPasswordFocus.requestFocus(),
        label: AppLocalizations.of(context)!.password,
        focus: passwordFocus,
        controller: passwordController,
        inputType: TextInputType.visiblePassword,
        password: true,
      ),
      SizedBox(height: height * c.loginPadding),
      CustomInputField(
        autofillHints: [AutofillHints.password],
        // onEditingComplete: () => signUpPressed(),
        textInputAction: TextInputAction.done,
        label: AppLocalizations.of(context)!.confirmPassword,
        focus: confirmPasswordFocus,
        controller: confirmPasswordController,
        inputType: TextInputType.visiblePassword,
        password: true,
      ),
      AnimatedBuilder(
        animation:
            Listenable.merge([passwordController, confirmPasswordController]),
        builder: (context, _) {
          final pass1 = passwordController.text;
          final pass2 = confirmPasswordController.text;
          final passed = _getPassedList(pass1, pass2);
          final List<String> emojiPassed = List.generate(
              6, (index) => passed[index] ? '✅' : '❌',
              growable: false);
          final filteredListLength = passed.where((item) => item).length;
          final passedPercent =
              pass1.isEmpty ? 0.0 : filteredListLength / passed.length;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 24,
                ),
                child: LinearProgressIndicator(
                  minHeight: 12,
                  value: passedPercent,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${emojiPassed[0]}${AppLocalizations.of(context)!.passwordLen}\n'
                  '${emojiPassed[1]}${AppLocalizations.of(context)!.passwordLower}\n'
                  '${emojiPassed[2]}${AppLocalizations.of(context)!.passwordUpper}\n'
                  '${emojiPassed[3]}${AppLocalizations.of(context)!.passwordNumber}\n'
                  '${emojiPassed[4]}${AppLocalizations.of(context)!.passwordSpecial}\n'
                  '${emojiPassed[5]}${AppLocalizations.of(context)!.passwordMatch}\n',
                  style: const TextStyle(fontSize: 16),
                ),
              )
            ],
          );
        },
      )
    ]);
  }
}
