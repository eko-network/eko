import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as prov;
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/providers/auth_provider.dart';
import 'package:untitled_app/providers/online_provider.dart';
import '../utilities/constants.dart' as c;

class InvalidSessionPage extends ConsumerWidget {
  const InvalidSessionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = c.widthGetter(context);
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
                      // prov.Provider.of<InvalidSessionPageController>(context,
                      //         listen: false)
                      //     .validate(),
                      ref
                          .read(onlineProvider(ref.read(authProvider).uid!)
                              .notifier)
                          .validateSession(),
                  style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary),
                  child: Text(
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
  }
}
