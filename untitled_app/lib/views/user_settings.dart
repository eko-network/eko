import 'package:flutter/material.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';

//import '../utilities/constants.dart' as c;
import '../controllers/settings_controller.dart';
import 'package:provider/provider.dart' as prov;
import 'package:go_router/go_router.dart';

//import 'package:cloud_firestore/cloud_firestore.dart';

class UserSettings extends StatelessWidget {
  const UserSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return prov.ChangeNotifierProvider(
      create: (context) => SettingsController(context: context),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => context.pop('poped'),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              AppLocalizations.of(context)!.settings,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          body: ListView(
            children: [
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.darkMode),
                value:
                    prov.Provider.of<SettingsController>(context, listen: false)
                        .getThemeValue(),
                onChanged: (value) {
                  prov.Provider.of<SettingsController>(context, listen: false)
                      .changeValue(value);
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!
                    .newActivityNotifications), // TODO: add localization
                value:
                    prov.Provider.of<SettingsController>(context, listen: true)
                        .activityNotification,
                // value: prov.Provider.of<NotificationProvider>(context, listen: true).notificationEnabled,
                onChanged: (value1) {
                  prov.Provider.of<SettingsController>(context, listen: false)
                      .toggleActivityNotification(value1);
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              ListTile(
                  title: Text(AppLocalizations.of(context)!.blockedAccounts),
                  leading: const Icon(Icons.no_accounts_outlined),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () => prov.Provider.of<SettingsController>(context,
                          listen: false)
                      .blockedPressed()),
              TextButton(
                onPressed: () {
                  prov.Provider.of<SettingsController>(context, listen: false)
                      .signOut();
                },
                child: Text(
                  AppLocalizations.of(context)!.logOut,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              TextButton(
                onPressed: () =>
                    prov.Provider.of<SettingsController>(context, listen: false)
                        .deleteAccount(),
                child: Text(
                  AppLocalizations.of(context)!.deleteAccount,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
