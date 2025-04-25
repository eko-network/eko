import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';

Widget? getAppFabBuilder() {
  if (kIsWeb) return const GetAppFab();
  return null;
}

class GetAppFab extends StatelessWidget {
  const GetAppFab({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: ButtonStyle(

        backgroundColor:
            WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
         side: WidgetStateProperty.all(
            BorderSide.none),
        // Set the shape of the button
        shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ),
      // Set the button label
      child: Text(AppLocalizations.of(context)!.getTheApp,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
      // Set the button action
      onPressed: () => context.go('/download'),
    );
  }
}
