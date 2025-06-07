import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled_app/custom_widgets/warning_dialog.dart';
import 'package:untitled_app/interfaces/user.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'package:untitled_app/models/shared_pref_model.dart';
import 'package:untitled_app/providers/current_user_provider.dart';
import 'package:untitled_app/providers/nav_bar_provider.dart';
import 'package:untitled_app/providers/theme_provider.dart';
import 'package:go_router/go_router.dart';

//import 'package:cloud_firestore/cloud_firestore.dart';

class UserSettings extends ConsumerStatefulWidget {
  const UserSettings({super.key});

  @override
  ConsumerState<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends ConsumerState<UserSettings> {
  late bool activityNotification;

  void toggleActivityNotification(bool value) {
    setActivityNotification(value);
    setState(() {
      activityNotification = value;
    });
    if (value) {
      addFCM(ref.read(currentUserProvider).user.uid);
    } else {
      removeFCM(ref.read(currentUserProvider).user.uid);
    }
  }

  @override
  void initState() {
    activityNotification = getActivityNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            value: ref.watch(colorThemeProvider).brightness == Brightness.dark,
            onChanged: (value) {
              ref.read(colorThemeProvider.notifier).changeTheme(value);
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.newActivityNotifications),
            value: activityNotification,
            // value: prov.Provider.of<NotificationProvider>(context, listen: true).notificationEnabled,
            onChanged: (value1) {
              toggleActivityNotification(value1);
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.blockedAccounts),
            leading: const Icon(Icons.no_accounts_outlined),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () => context.pushNamed('blocked_users'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(currentUserProvider.notifier).signOut();
              ref.read(navBarProvider.notifier).enable();
            },
            child: Text(
              AppLocalizations.of(context)!.logOut,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () {
              showMyDialog(
                  AppLocalizations.of(context)!.deleteAcountTitle,
                  AppLocalizations.of(context)!.deleteAcountBody,
                  [
                    AppLocalizations.of(context)!.goBack,
                    AppLocalizations.of(context)!.delete
                  ],
                  [
                    context.pop,
                    () async {
                      context.pop();
                      try {
                        await FirebaseAuth.instance.currentUser?.delete();
                        ref.read(navBarProvider.notifier).enable();
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'requires-recent-login') {
                          if (context.mounted) context.pushNamed('re_auth');
                        }
                      }
                    }
                  ],
                  context);
            },
            child: Text(
              AppLocalizations.of(context)!.deleteAccount,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
