import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utilities/constants.dart' as c;

class CustomInputField extends StatefulWidget {
  const CustomInputField({super.key});

  @override
  State<CustomInputField> createState() => _CustomInputField();
}

class _CustomInputField extends State<CustomInputField> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class CustomInputFeild extends StatelessWidget {
  final int? maxLen;
  final String? label;
  final TextEditingController controller;
  final String? Function(String?)? validatorFunction;
  final AutovalidateMode validator;
  final TextInputType inputType;
  final FocusNode? focus;
  final String filter;
  final double? width;
  final bool enabled;
  final bool password;
  final bool padding;
  final bool showCounter;
  final TextInputAction textInputAction;
  final double? height;

  final void Function(String)? onChanged;
  final void Function()? onEditingComplete;
  const CustomInputFeild(
      {this.label,
      required this.controller,
      this.onChanged,
      this.maxLen,
      this.padding = true,
      this.onEditingComplete,
      this.focus,
      this.width,
      this.height,
      this.showCounter = true,
      this.inputType = TextInputType.text,
      this.filter = r'[\s\S]*',
      this.validator = AutovalidateMode.disabled,
      this.validatorFunction,
      this.enabled = true,
      this.password = false,
      this.textInputAction = TextInputAction.next,
      super.key});

  @override
  Widget build(BuildContext context) {
    double feildWidth;
    bool hidden = password;

    if (width == null) {
      feildWidth = c.widthGetter(context) * 0.9;
    } else {
      feildWidth = width!;
    }
    return Container(
      alignment: Alignment.bottomCenter,
      padding: padding
          ? const EdgeInsets.only(top: 10, bottom: 10)
          : const EdgeInsets.only(),
      width: feildWidth,
      height: height,
      child: TextFormField(
        maxLength: maxLen,
        cursorColor: Theme.of(context).colorScheme.onSurface,
        obscureText: hidden,

        enabled: enabled,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(filter)),
        ],
        textInputAction: textInputAction,
        autovalidateMode: validator,
        validator: validatorFunction,
        controller: controller,
        focusNode: focus,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        //autofocus: true,
        keyboardType: inputType,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          counterText: showCounter ? null : '',
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 18,
            letterSpacing: 1,
            fontWeight: FontWeight.normal,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          fillColor:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.onSurface)),
          suffixIcon: password
              ? IconButton(
                  icon: Icon(hidden ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    hidden = !hidden;
                  })
              : null,
        ),
      ),
    );
  }
}
