import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:untitled_app/interfaces/uri_launcher.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/utilities/constants.dart' as c;
import 'package:untitled_app/utilities/version.dart';

class CheckVersion extends StatelessWidget {
  final Widget? child;
  const CheckVersion({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (child == null) return SizedBox();
    return kIsWeb ? child! : _CheckVersonMobile(child: child!);
  }
}

class _CheckVersonMobile extends StatefulWidget {
  final Widget child;
  const _CheckVersonMobile({required this.child});

  @override
  State<_CheckVersonMobile> createState() => _CheckVersonMobileState();
}

class _CheckVersonMobileState extends State<_CheckVersonMobile> {
  bool needsUpdate = false;
  Future<void> _check() async {
    final version = Version();
    await version.init();
    if (version.lessThanMin) {
      setState(() {
        needsUpdate = true;
      });
    }
  }

  @override
  void initState() {
    _check();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    return needsUpdate
        ? Scaffold(
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
                          backgroundColor:
                              Theme.of(context).colorScheme.primary),
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
              ),
            ),
          )
        : widget.child;
  }
}
