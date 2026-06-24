import 'dart:convert';

import 'package:ecp/ecp.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/messenger/providers/approval_stream_provider.dart';
import 'package:eko_app/messenger/utilities/device_public_key.dart';
import 'package:eko_app/messenger/widgets/pub_key.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:eko_app/widgets/auth/auth_button.dart';
import 'package:eko_app/widgets/common/icons.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _InvalidCodeException implements Exception {}

class ApprovalView extends ConsumerStatefulWidget {
  final StoredApprovalRequest request;
  const ApprovalView({super.key, required this.request});

  @override
  ConsumerState<ApprovalView> createState() => _ApprovalViewState();
}

class _ApprovalViewState extends ConsumerState<ApprovalView> {
  final TextEditingController controller = TextEditingController();
  bool _isApproving = false;
  bool _isIgnoring = false;

  String get _publicKey => base64Encode(widget.request.publicKey);

  bool get _canApprove =>
      !_isApproving && !_isIgnoring && controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onCodeChanged);
  }

  void _onCodeChanged() => setState(() {});

  @override
  void dispose() {
    controller.removeListener(_onCodeChanged);
    controller.dispose();
    super.dispose();
  }

  Future<void> delete() async {
    await ref
        .read(validatedApprovalProvider.notifier)
        .deleteRequest(widget.request.did);
  }

  Future<void> _onIgnore() async {
    if (_isIgnoring || _isApproving) return;
    setState(() => _isIgnoring = true);
    try {
      await delete();
    } finally {
      if (mounted) setState(() => _isIgnoring = false);
    }
  }

  Future<void> approve() async {
    final deviceCode = devicePublicKeyCode(widget.request.publicKey);
    if (deviceCode != controller.text.trim()) {
      throw _InvalidCodeException();
    }
    await supabase.rpc('approve_device', params: {'did': widget.request.did});
    await delete();
  }

  Future<void> _onApprove() async {
    if (!_canApprove) return;
    setState(() => _isApproving = true);
    try {
      await approve();
    } on _InvalidCodeException {
      debugPrint('[Approval Screen] Invalid Code');
      if (!mounted) return;
      showSnackBar(
        text: AppLocalizations.of(context)!.messengerInvalidDeviceCode,
        context: context,
        variant: SnackBarVariant.destructive,
      );
    } catch (e) {
      debugPrint('[Approval Screen] Error: $e');

      if (!mounted) return;
      showSnackBar(
        text: AppLocalizations.of(context)!.deviceRegistrationFailed,
        context: context,
        variant: SnackBarVariant.destructive,
      );
    } finally {
      if (mounted) setState(() => _isApproving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                    l10n.messengerApproveDeviceTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.messengerApproveDeviceBody,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.messengerEnterDeviceCode,
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
                      child: TextField(
                        controller: controller,
                        enabled: !_isApproving && !_isIgnoring,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 4,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          isDense: true,
                        ),
                        onSubmitted: _canApprove ? (_) => _onApprove() : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  PubKey(publicKey: widget.request.publicKey),
                  const SizedBox(height: 32),
                  AuthButton.primary(
                    label: l10n.messengerApproveDevice,
                    onPressed: _canApprove ? _onApprove : null,
                    isLoading: _isApproving,
                  ),
                  const SizedBox(height: 12),
                  AuthButton.secondary(
                    label: l10n.messengerIgnoreDevice,
                    onPressed: _isApproving || _isIgnoring ? null : _onIgnore,
                    isLoading: _isIgnoring,
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
