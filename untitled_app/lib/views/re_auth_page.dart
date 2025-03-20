import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:untitled_app/controllers/re_auth_page_controller.dart';
import 'package:untitled_app/custom_widgets/login_text_feild.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/utilities/constants.dart' as c;

class ReAuthPage extends StatelessWidget {
  const ReAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = c.widthGetter(context);
    return ChangeNotifierProvider(
      create: (context) => ReAuthPageController(context: context),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => context.pop(),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              AppLocalizations.of(context)!.deleteAccount,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          body: Center(child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // =mainAxisSize: MainAxisSize.min,
            

            
            children: [
              SizedBox(
                    height: width * 0.05,
                  ),
              SizedBox(
                  width: width * 0.7,
                  child: Text(
                      AppLocalizations.of(context)!.deleteAcountReAuthWarning,
                      textAlign: TextAlign.center)),
              SizedBox(
                    height: width * 0.2,
                  ),
              CustomInputFeild(
                textInputAction: TextInputAction.go,
                // onEditingComplete: () =>
                //     Provider.of<LoginController>(context, listen: false)
                //         .logInPressed(),
                focus: Provider.of<ReAuthPageController>(context, listen: false)
                    .passwordFocus,
                label: AppLocalizations.of(context)!.password,
                controller:
                    Provider.of<ReAuthPageController>(context, listen: false)
                        .passwordController,
                inputType: TextInputType.visiblePassword,
                password: true,
              ),
              SizedBox(
                    height: width * 0.05,
                  ),
              InkWell(
                child: Container(
                  alignment: Alignment.center,
                  height: width * 0.15,
                  width: width * 0.9,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Theme.of(context).colorScheme.primary),
                  child: Text(AppLocalizations.of(context)!.deleteAccount,
                      style: TextStyle(
                          fontSize: width * 0.06,
                          color: Theme.of(context).colorScheme.onPrimary),
                      textAlign: TextAlign.center),
                ),
                onTap: ()=> Provider.of<ReAuthPageController>(context, listen: false)
                    .buttonTap(),
              ),
              SizedBox(height: width * 0.05)
            ],
          )),
        );
      },
    );
  }
}
