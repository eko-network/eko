import 'package:flutter/material.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import '../utilities/constants.dart' as c;
import '../interfaces/uri_launcher.dart';

class UpdateRequiredPage extends StatelessWidget {
  const UpdateRequiredPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(AppLocalizations.of(context)!.updateRequiredTitle),
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.transparent,
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: width * 0.8,
              child: Text(
                AppLocalizations.of(context)!.updateRequiredBody,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 23),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: width * 0.45,
              height: width * 0.15,
              child: TextButton(
                onPressed: () => UriLauncher.launchCorrectStore(),
                style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary),
                child: Text(
                  AppLocalizations.of(context)!.update,
                  style: TextStyle(
                    fontSize: 18,
                    letterSpacing: 1,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
