import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/messenger/providers/devices_provider.dart';
import 'package:eko_app/messenger/utilities/device_public_key.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/providers/ecp_provider.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:eko_app/widgets/errors/dialogs.dart';
import 'package:eko_app/widgets/errors/snack_bar.dart';
import 'package:eko_app/widgets/loading/loading_spinner.dart';
import 'package:eko_app/widgets/scaffolds/app_scaffold.dart';
import 'package:eko_app/widgets/scaffolds/eko_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DevicesPage extends ConsumerStatefulWidget {
  const DevicesPage({super.key});

  @override
  ConsumerState<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends ConsumerState<DevicesPage> {
  String? _removingId;

  Future<void> _confirmRemove(MessengerDevice device) async {
    final l10n = AppLocalizations.of(context)!;
    await showMyDialog(
      l10n.messengerRemoveDeviceTitle,
      l10n.messengerRemoveDeviceBody,
      [l10n.cancel, l10n.messengerRemoveDevice],
      [
        context.pop,
        () {
          context.pop();
          _remove(device);
        },
      ],
      context,
      dismissable: true,
    );
  }

  Future<void> _remove(MessengerDevice device) async {
    setState(() => _removingId = device.id);
    try {
      // drop the record first so the server stops routing to the device, then
      // take it out of the groups this device can commit to
      await supabase.rpc('remove_device', params: {'p_did': device.id});
      final client = ref.read(asyncEcpClientProvider).value;
      if (client != null) {
        try {
          await client.groups.removeDeviceFromGroups(
            publicKey: device.signerPublicKey,
          );
        } catch (e) {
          debugPrint('[DevicesPage] removing device from chats failed: $e');
        }
      }
      ref.invalidate(messengerDevicesProvider);
    } catch (e) {
      debugPrint('[DevicesPage] remove_device failed: $e');
      if (!mounted) return;
      showSnackBar(
        text: AppLocalizations.of(context)!.messengerRemoveDeviceFailed,
        context: context,
        variant: SnackBarVariant.destructive,
      );
    } finally {
      if (mounted) setState(() => _removingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final devices = ref.watch(messengerDevicesProvider);
    final currentDevice = ref.watch(authProvider).value?.device;
    // removing other devices requires this one to be approved
    final canRemove = currentDevice?.dat != null;

    return AppScaffold(
      contrainBody: true,
      appBar: EkoAppBar(title: Text(l10n.messengerDevicesTitle)),
      body: devices.when(
        loading: () => const Center(child: LoadingSpinner()),
        error: (e, _) => Center(child: Text(l10n.messengerDevicesLoadFailed)),
        data: (list) => RefreshIndicator(
          onRefresh: () => ref.refresh(messengerDevicesProvider.future),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final device = list[index];
              final isCurrent = device.id == currentDevice?.did;
              return _DeviceTile(
                device: device,
                isCurrent: isCurrent,
                isRemoving: _removingId == device.id,
                onRemove: !isCurrent && canRemove && _removingId == null
                    ? () => _confirmRemove(device)
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final MessengerDevice device;
  final bool isCurrent;
  final bool isRemoving;
  final VoidCallback? onRemove;

  const _DeviceTile({
    required this.device,
    required this.isCurrent,
    required this.isRemoving,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final added = l10n.messengerDeviceAdded(
      DateFormat.yMMMd(locale).format(device.createdAt.toLocal()),
    );

    // a pending device's code is what approves it, so it is only shown on
    // that device itself
    final title = isCurrent
        ? l10n.messengerThisDevice
        : device.isApproved
        ? l10n.messengerDeviceName(devicePublicKeyCode(device.signerPublicKey))
        : l10n.messengerDevicePending;

    return ListTile(
      leading: Icon(
        device.isApproved ? LucideIcons.smartphone : LucideIcons.hourglass,
      ),
      title: Text(title),
      subtitle: Text(
        isCurrent && !device.isApproved
            ? '${l10n.messengerDevicePending} · $added'
            : added,
      ),
      trailing: isRemoving
          ? const LoadingSpinner(width: 24)
          : onRemove == null
          ? null
          : TextButton(
              onPressed: onRemove,
              child: Text(
                l10n.messengerRemoveDevice,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
    );
  }
}
