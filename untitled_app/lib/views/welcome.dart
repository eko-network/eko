import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled_app/custom_widgets/download_button_if_web.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/widgets/icons.dart';
import '../utilities/constants.dart' as c;

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      floatingActionButton: downloadButtonIfWeb(),
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
      body: Container(
        height: height,
        width: MediaQuery.sizeOf(context).width,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/fog1.gif'), fit: BoxFit.cover)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: height * .2,
            ),
            SizedBox(
              width: width * 0.7,
              child: Eko(),
            ),
            SizedBox(
              height: height * .28,
            ),
            OutlinedButton(
              onPressed: () => context.push('/login'),
              style: OutlinedButton.styleFrom(
                side:
                    BorderSide(color: Theme.of(context).colorScheme.onSurface),
                backgroundColor: Colors.transparent,
                minimumSize: Size(width * .8, height * .07),
              ),
              child: Text(AppLocalizations.of(context)!.logIn,
                  style: TextStyle(
                      fontSize: 22,
                      color: Theme.of(context).colorScheme.onSurface)),
            ),
            SizedBox(
              height: height * .03,
            ),
            OutlinedButton(
              onPressed: () => context.push('/signup'),
              style: OutlinedButton.styleFrom(
                side:
                    BorderSide(color: Theme.of(context).colorScheme.onSurface),
                backgroundColor: Colors.transparent,
                minimumSize: Size(width * .8, height * .07),
              ),
              child: Text(AppLocalizations.of(context)!.createAccount,
                  style: TextStyle(
                      fontSize: 22,
                      color: Theme.of(context).colorScheme.onSurface)),
            ),
          ],
        ),
      ),
    );
  }
}
