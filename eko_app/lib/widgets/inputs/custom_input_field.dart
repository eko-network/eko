import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:eko_app/utilities/constants.dart' as c;

class CustomInputField extends StatefulWidget {
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
  final bool showPasswordToggle;
  final bool padding;
  final bool showCounter;
  final TextInputAction textInputAction;
  final double? height;
  final Iterable<String>? autofillHints;

  final void Function(String)? onChanged;
  final void Function()? onEditingComplete;
  final void Function(bool)? onPasswordHiddenChanged;
  const CustomInputField({
    this.label,
    required this.controller,
    this.onChanged,
    this.maxLen,
    this.padding = true,
    this.onEditingComplete,
    this.focus,
    this.autofillHints,
    this.width,
    this.height,
    this.showCounter = true,
    this.inputType = TextInputType.text,
    this.filter = r'[\s\S]*',
    this.validator = AutovalidateMode.disabled,
    this.validatorFunction,
    this.enabled = true,
    this.password = false,
    this.showPasswordToggle = true,
    this.textInputAction = TextInputAction.next,
    this.onPasswordHiddenChanged,
    super.key,
  });

  @override
  State<CustomInputField> createState() => _CustomInputField();
}

class _CustomInputField extends State<CustomInputField> {
  bool hidden = false;
  @override
  void initState() {
    super.initState();
    if (widget.password) {
      hidden = true;
      widget.onPasswordHiddenChanged?.call(hidden);
    }
  }

  @override
  Widget build(BuildContext context) {
    double fieldWidth;

    if (widget.width == null) {
      fieldWidth = c.widthGetter(context) * 0.9;
    } else {
      fieldWidth = widget.width!;
    }
    return Container(
      alignment: Alignment.bottomCenter,
      padding: widget.padding
          ? const EdgeInsets.only(top: 10, bottom: 10)
          : const EdgeInsets.only(),
      width: fieldWidth,
      height: widget.height,
      child: TextFormField(
        autofillHints: widget.autofillHints,
        maxLength: widget.maxLen,
        cursorColor: Theme.of(context).colorScheme.onSurface,
        obscureText: hidden,
        enabled: widget.enabled,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(widget.filter)),
        ],
        textInputAction: widget.textInputAction,
        autovalidateMode: widget.validator,
        validator: widget.validatorFunction,
        controller: widget.controller,
        focusNode: widget.focus,
        onChanged: widget.onChanged,
        onEditingComplete: widget.onEditingComplete,
        keyboardType: widget.inputType,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          counterText: widget.showCounter ? null : '',
          labelText: widget.label,
          labelStyle: TextStyle(
            fontSize: 18,
            letterSpacing: 1,
            fontWeight: FontWeight.normal,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          fillColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.2),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          suffixIcon: widget.password && widget.showPasswordToggle
              ? IconButton(
                  icon: Icon(hidden ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      hidden = !hidden;
                    });
                    widget.onPasswordHiddenChanged?.call(hidden);
                  },
                )
              : null,
        ),
      ),
    );
  }
}
