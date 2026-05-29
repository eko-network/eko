import 'package:eko_app/widgets/scaffolds/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eko_app/widgets/errors/dialogs.dart';
import 'package:eko_app/interfaces/user.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/utilities/shared_pref_service.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/providers/nav_bar_provider.dart';
import 'package:eko_app/providers/theme_provider.dart';
import 'package:eko_app/providers/post_preview_provider.dart';
import 'package:eko_app/interfaces/notification_helper.dart';
import 'package:eko_app/widgets/scaffolds/eko_app_bar.dart';
import 'package:go_router/go_router.dart';

class UserSettings extends ConsumerStatefulWidget {
  const UserSettings({super.key});

  @override
  ConsumerState<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends ConsumerState<UserSettings> {
  late bool activityNotification;

  Future<void> toggleActivityNotification(bool value) async {
    PrefsService.notificationsEnabled = value;
    setState(() {
      activityNotification = value;
    });
    if (value) {
      await NotificationHelper.setupNotifications();
      await addDeviceNotificationToken(ref.read(currentUserProvider).user.uid);
    } else {
      await removeDeviceNotificationToken(
        ref.read(currentUserProvider).user.uid,
      );
    }
  }

  Map<String, String> _userProfilePathParams() {
    return {'username': ref.read(currentUserProvider).user.username};
  }

  @override
  void initState() {
    activityNotification = PrefsService.notificationsEnabled;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      contrainBody: true,
      appBar: EkoAppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.darkMode),
            value: ref.watch(colorThemeProvider).brightness == Brightness.dark,
            onChanged: (value) {
              ref.read(colorThemeProvider.notifier).changeTheme(value);
            },
            activeThumbColor: Theme.of(context).colorScheme.primary,
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.newActivityNotifications),
            value: activityNotification,
            // value: prov.Provider.of<NotificationProvider>(context, listen: true).notificationEnabled,
            onChanged: (value1) {
              toggleActivityNotification(value1);
            },
            activeThumbColor: Theme.of(context).colorScheme.primary,
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.showPostPreview),
            value: ref.watch(postPreviewProvider),
            onChanged: (value) {
              if (value == false &&
                  !ref.read(postPreviewProvider.notifier).hasShownInfo()) {
                showMyDialog(
                  AppLocalizations.of(context)!.postPreviewInfoTitle,
                  AppLocalizations.of(context)!.postPreviewInfoBody,
                  [AppLocalizations.of(context)!.ok],
                  [
                    () {
                      context.pop();
                      ref.read(postPreviewProvider.notifier).toggle();
                      ref.read(postPreviewProvider.notifier).markInfoShown();
                    },
                  ],
                  context,
                );
              } else {
                ref.read(postPreviewProvider.notifier).toggle();
              }
            },
            activeThumbColor: Theme.of(context).colorScheme.primary,
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.changeEmail),
            leading: const Icon(Icons.alternate_email),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () => context.pushNamed(
              'change_email',
              pathParameters: _userProfilePathParams(),
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.changePassword),
            leading: const Icon(Icons.lock_outline),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () => context.pushNamed(
              'change_password',
              pathParameters: _userProfilePathParams(),
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.blockedAccounts),
            leading: const Icon(Icons.no_accounts_outlined),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () => context.pushNamed(
              'blocked_users',
              pathParameters: {
                'username': ref.read(currentUserProvider).user.username,
              },
            ),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(currentUserProvider.notifier).signOut();
              if (!mounted) return;
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
                AppLocalizations.of(context)!.deleteAccountTitle,
                AppLocalizations.of(context)!.deleteAccountBody,
                [
                  AppLocalizations.of(context)!.goBack,
                  AppLocalizations.of(context)!.delete,
                ],
                [
                  context.pop,
                  () async {
                    context.pop();
                    try {
                      await ref.read(authProvider.notifier).deleteAccount();
                      ref.read(navBarProvider.notifier).enable();
                    } on Exception catch (e) {
                      if (e.toString().contains('requires-recent-login')) {
                        if (context.mounted) {
                          context.pushNamed(
                            're_auth',
                            pathParameters: _userProfilePathParams(),
                          );
                        }
                      }
                    }
                  },
                ],
                context,
              );
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
