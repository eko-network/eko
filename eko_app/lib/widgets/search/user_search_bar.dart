import 'package:flutter/material.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/utilities/constants.dart' as c;

class UserSearchBar extends StatelessWidget {
  final TextEditingController controller;
  const UserSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;
    return DecoratedBox(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: TextField(
        cursorColor: Theme.of(context).colorScheme.onSurface,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(height * 0.01),
          prefixIcon: Icon(
            Icons.search,
            size: width * 0.05,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          hintText: AppLocalizations.of(context)!.search,
          filled: true,
          fillColor: Theme.of(context).colorScheme.outlineVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide.none,
          ),
        ),
        controller: controller,
        keyboardType: TextInputType.text,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
