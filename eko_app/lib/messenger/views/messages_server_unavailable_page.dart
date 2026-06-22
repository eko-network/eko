import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/ecp_provider.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/widgets/auth/auth_button.dart';
import 'package:eko_app/widgets/common/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessagesServerUnavailablePage extends ConsumerWidget {
  const MessagesServerUnavailablePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isRetrying = ref.watch(asyncEcpClientProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
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
                    l10n.messengerServerUnavailableTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.messengerServerUnavailableBody,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  AuthButton(
                    label: l10n.tryAgain,
                    onPressed: isRetrying
                        ? null
                        : () => ref.invalidate(asyncEcpClientProvider),
                    isLoading: isRetrying,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
