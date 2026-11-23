import 'package:material_ui/material_ui.dart';
import 'package:eko_app/widgets/inputs/custom_input_field.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/utilities/constants.dart' as c;

List<bool> _getSimplePassedList(String pass1, String pass2) {
  final List<bool> passed = List.generate(2, (index) => false, growable: false);
  passed[0] = pass1.length >= 8;
  passed[1] = pass1 == pass2 && pass1 != '';
  return passed;
}

bool isValidSimplePassword(
  String pass1,
  String pass2, {
  bool requireMatch = true,
}) {
  if (!requireMatch) {
    return pass1.length >= 8;
  }
  return _getSimplePassedList(pass1, pass2).where((item) => item).length == 2;
}

class CreatePassword extends StatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode passwordFocus;
  final FocusNode confirmPasswordFocus;
  final void Function(bool)? onRequirePasswordMatchChanged;
  const CreatePassword({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.passwordFocus,
    required this.confirmPasswordFocus,
    this.onRequirePasswordMatchChanged,
  });

  @override
  State<CreatePassword> createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {
  bool isMainPasswordHidden = true;

  void _onMainPasswordHiddenChanged(bool hidden) {
    if (isMainPasswordHidden == hidden) return;
    setState(() {
      isMainPasswordHidden = hidden;
    });
    widget.onRequirePasswordMatchChanged?.call(hidden);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Column(
      children: [
        CustomInputField(
          autofillHints: [AutofillHints.password],
          onEditingComplete: () {
            if (isMainPasswordHidden) {
              widget.confirmPasswordFocus.requestFocus();
            }
          },
          label: AppLocalizations.of(context)!.password,
          focus: widget.passwordFocus,
          controller: widget.passwordController,
          inputType: TextInputType.visiblePassword,
          password: true,
          onPasswordHiddenChanged: _onMainPasswordHiddenChanged,
        ),
        SizedBox(height: height * c.loginPadding),
        if (isMainPasswordHidden)
          CustomInputField(
            autofillHints: [AutofillHints.password],
            textInputAction: TextInputAction.done,
            label: AppLocalizations.of(context)!.confirmPassword,
            focus: widget.confirmPasswordFocus,
            controller: widget.confirmPasswordController,
            inputType: TextInputType.visiblePassword,
            password: true,
            showPasswordToggle: false,
          ),
        AnimatedBuilder(
          animation: Listenable.merge([
            widget.passwordController,
            widget.confirmPasswordController,
          ]),
          builder: (context, _) {
            final pass1 = widget.passwordController.text;
            final pass2 = widget.confirmPasswordController.text;
            final passed = isMainPasswordHidden
                ? _getSimplePassedList(pass1, pass2)
                : [pass1.length >= 8];
            final metColor = Colors.green;
            final unmetColor = Theme.of(context).colorScheme.onSurface;
            return Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.passwordMinChars,
                        style: TextStyle(
                          fontSize: 16,
                          color: passed[0] ? metColor : unmetColor,
                        ),
                      ),
                      if (isMainPasswordHidden)
                        Text(
                          AppLocalizations.of(context)!.passwordMatch,
                          style: TextStyle(
                            fontSize: 16,
                            color: passed[1] ? metColor : unmetColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
