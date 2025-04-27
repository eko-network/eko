import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as prov;
import 'package:untitled_app/controllers/invalid_session_page_controller.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import '../utilities/constants.dart' as c;

class InvalidSessionPage extends StatelessWidget {
  const InvalidSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    return prov.ChangeNotifierProvider(
      create: (context) => InvalidSessionPageController(),
      builder: (context, child) {
        return Scaffold(
          body: PopScope(
            canPop: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: width * 0.8,
                    child: Text(
                      AppLocalizations.of(context)!.invalidSession,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: width * 0.45,
                    height: width * 0.15,
                    child: TextButton(
                      onPressed: () =>
                          prov.Provider.of<InvalidSessionPageController>(
                                  context,
                                  listen: false)
                              .validate(),
                      style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary),
                      child: prov.Provider.of<InvalidSessionPageController>(
                                  context)
                              .loading
                          ? const CircularProgressIndicator()
                          : Text(
                              AppLocalizations.of(context)!.cont,
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
              ),
            ),
          ),
        );
      },
    );
  }
}
