import 'dart:async';
import 'dart:convert';

import 'package:eko_app/messenger/utilities/device_public_key.dart';
import 'package:eko_app/database/database.dart';
import 'package:eko_app/database/storage.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:eko_app/widgets/auth/auth_button.dart';
import 'package:eko_app/widgets/common/icons.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:eko_app/widgets/loading/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WaitForApproval extends ConsumerStatefulWidget {
  const WaitForApproval({super.key});

  @override
  ConsumerState<WaitForApproval> createState() => _WaitForApprovalState();
}

class _WaitForApprovalState extends ConsumerState<WaitForApproval> {
  String? _publicKey;
  String? _deviceCode;
  bool _loadingKey = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadPublicKey();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      supabase.auth.refreshSession();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPublicKey() async {
    final credential = await AppStorage(db).mlsCredentialStore.getCredential();
    if (!mounted) return;
    setState(() {
      if (credential != null) {
        _publicKey = base64Encode(credential.signerPublicKey);
        _deviceCode = devicePublicKeyCode(credential.signerPublicKey);
      } else {
        _publicKey = null;
        _deviceCode = null;
      }
      _loadingKey = false;
    });
  }

  void _copyText(String? text) {
    if (text == null || text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    showSnackBar(
      text: AppLocalizations.of(context)!.copiedToClipboard,
      context: context,
    );
  }

  void _copyPublicKey() => _copyText(_publicKey);

  void _copyDeviceCode() => _copyText(_deviceCode);

  void _resendNotification() {
    // TODO: resend approval notification to active devices
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
                    l10n.messengerWaitForApprovalTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.messengerWaitForApprovalBody,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (_loadingKey)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: LoadingSpinner(),
                    )
                  else ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.messengerDeviceCode,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: SelectableText(
                                _deviceCode ?? '—',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                            if (_deviceCode != null)
                              IconButton(
                                tooltip: l10n.copyLink,
                                icon: const Icon(Icons.copy_outlined, size: 20),
                                onPressed: _copyDeviceCode,
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.messengerDevicePublicKey,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SelectableText(
                                _publicKey ?? '—',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            if (_publicKey != null) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: l10n.copyLink,
                                icon: const Icon(Icons.copy_outlined, size: 20),
                                onPressed: _copyPublicKey,
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    AuthButton.secondary(
                      label: l10n.messengerResendApprovalNotification,
                      onPressed: _resendNotification,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
