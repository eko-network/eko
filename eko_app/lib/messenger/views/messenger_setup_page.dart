import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/ecp_core_provider.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/widgets/auth/auth_button.dart';
import 'package:eko_app/widgets/common/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessengerSetupPage extends ConsumerWidget {
  const MessengerSetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isRegistering = ref.watch(ecpCoreHolderProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 120,
                width: c.widthGetter(context) * 0.5,
                child: Eko(useDefault: true),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.messengerTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.messengerSetupBody,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              AuthButton(
                label: isRegistering
                    ? l10n.registeringDevice
                    : l10n.enableMessages,
                onPressed: isRegistering
                    ? null
                    : () => ref
                          .read(ecpCoreHolderProvider.notifier)
                          .registerDevice(),
                isLoading: isRegistering,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
