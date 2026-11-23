import 'dart:convert';

import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/providers/ecp_core_provider.dart';
import 'package:eko_app/utilities/api_constants.dart' as ac;
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Explains a device reset, then emails a code and resets with it, see
/// [EcpCoreHolder.resetDevices]. Pops true once this device is the user's
/// only one.
///
/// Confirming the code swaps the session, which replaces the page below for
/// a moment, so the flow lives in this dialog rather than that page.
class ResetDevicesDialog extends ConsumerStatefulWidget {
  const ResetDevicesDialog({super.key});

  @override
  ConsumerState<ResetDevicesDialog> createState() => _ResetDevicesDialogState();
}

class _ResetDevicesDialogState extends ConsumerState<ResetDevicesDialog> {
  final _code = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _code.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, String error) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (e, st) {
      debugPrint('[ResetDevices] $e\n$st');
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendCode() {
    final l10n = AppLocalizations.of(context)!;
    return _run(() async {
      final email = supabase.auth.currentUser?.email ?? '';
      final before = ac.useLocal ? await _latestLocalMail(email) : null;
      await ref.read(ecpCoreHolderProvider.notifier).sendResetCode();
      if (mounted) setState(() => _codeSent = true);
      if (ac.useLocal) _fillLocalCode(email, before);
    }, l10n.messengerResetCodeSendFailed);
  }

  // the local stack catches mail in mailpit, so debug builds fill the code
  // in from there; the server still checks it like any other code
  Future<void> _fillLocalCode(
    String email,
    Map<String, dynamic>? before,
  ) async {
    for (var i = 0; i < 20 && mounted; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final mail = await _latestLocalMail(email);
      if (mail == null || mail['ID'] == before?['ID']) continue;
      final code = RegExp(r'\b\d{6}\b').firstMatch(mail['Snippet'] ?? '');
      if (code != null && mounted && _code.text.isEmpty) {
        _code.text = code[0]!;
      }
      return;
    }
  }

  Future<Map<String, dynamic>?> _latestLocalMail(String email) async {
    try {
      final api = Uri.parse(ac.supabaseUrl);
      final response = await http.get(
        api.replace(
          port: 54324,
          path: '/api/v1/search',
          queryParameters: {'query': 'to:"$email"', 'limit': '1'},
        ),
      );
      final messages = (jsonDecode(response.body) as Map)['messages'] as List;
      return messages.isEmpty ? null : messages.first as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[ResetDevices] local mail: $e');
      return null;
    }
  }

  Future<void> _reset() {
    final l10n = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
    return _run(() async {
      await ref
          .read(ecpCoreHolderProvider.notifier)
          .resetDevices(_code.text.trim());
      navigator.pop(true);
    }, l10n.messengerResetDevicesFailed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final email = supabase.auth.currentUser?.email ?? '';

    return AlertDialog(
      title: Text(l10n.messengerResetDevicesTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _codeSent
                ? l10n.messengerResetDevicesCodeBody(email)
                : l10n.messengerResetDevicesBody,
          ),
          if (_codeSent) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _code,
              autofocus: true,
              enabled: !_busy,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              decoration: InputDecoration(
                labelText: l10n.messengerResetDevicesCodeHint,
              ),
              onSubmitted: (_) => _code.text.trim().isEmpty ? null : _reset(),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        if (_codeSent)
          TextButton(
            onPressed: _busy ? null : _sendCode,
            child: Text(l10n.messengerResendCode),
          ),
        TextButton(
          onPressed: _busy || (_codeSent && _code.text.trim().isEmpty)
              ? null
              : _codeSent
              ? _reset
              : _sendCode,
          child: Text(
            _codeSent
                ? l10n.messengerResetDevices
                : l10n.messengerResetDevicesSendCode,
          ),
        ),
      ],
    );
  }
}
