import 'dart:convert';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PubKey extends StatelessWidget {
  final Uint8List publicKey;
  const PubKey({super.key, required this.publicKey});

  String get _publicKey => base64Encode(publicKey);
  @override
  Widget build(BuildContext context) {
    void copyPublicKey() {
      Clipboard.setData(ClipboardData(text: _publicKey));
      showSnackBar(
        text: AppLocalizations.of(context)!.copiedToClipboard,
        context: context,
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            l10n.messengerDevicePublicKey,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        // const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SelectableText(
                  _publicKey,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: l10n.copyLink,
                icon: const Icon(Icons.copy_outlined, size: 20),
                onPressed: copyPublicKey,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
