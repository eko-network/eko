import 'dart:async';

import 'package:ecp/ecp.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/messenger/ecp_helpers.dart';
import 'package:eko_app/providers/ecp_core_provider.dart';
import 'package:eko_app/providers/ecp_provider.dart';
import 'package:eko_app/providers/user_provider.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Asks whether to go ahead with [name] although their device chain no
/// longer extends the one seen before.
Future<bool> confirmDevicesChanged(BuildContext context, String name) async {
  final l10n = AppLocalizations.of(context)!;
  final accepted = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.messengerDevicesChangedTitle(name)),
      content: Text(l10n.messengerDevicesChangedBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.messengerDevicesChangedContinue),
        ),
      ],
    ),
  );
  return accepted ?? false;
}

/// Shows the messenger client's [GroupManager.deviceWarnings], one dialog at
/// a time.
class DeviceWarningHandler extends ConsumerStatefulWidget {
  final Widget child;
  const DeviceWarningHandler({super.key, required this.child});

  @override
  ConsumerState<DeviceWarningHandler> createState() =>
      _DeviceWarningHandlerState();
}

class _DeviceWarningHandlerState extends ConsumerState<DeviceWarningHandler> {
  StreamSubscription<GroupDeviceWarning>? _subscription;
  Future<void> _shown = Future.value();

  // warnings queued or on screen, so checks repeated meanwhile don't stack
  // up the same dialog
  final _pending = <(Uri, Uri?, bool)>{};

  // users whose device reset was accepted here, their old devices being
  // removed from chats afterwards is expected
  final _accepted = <Uri>{};

  @override
  void initState() {
    super.initState();
    ref.listenManual(asyncEcpClientProvider, (_, next) {
      _subscription?.cancel();
      final groups = next.value?.groups;
      _subscription = groups?.deviceWarnings.listen(_queue);
      // warns again about chats still hidden from before, e.g. ones joined
      // while the app was in the background
      groups?.verifyHiddenGroups().catchError(
        (Object e) => debugPrint('[DeviceWarning] verifyHiddenGroups: $e'),
      );
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _queue(GroupDeviceWarning warning) {
    if (!warning.unverified &&
        warning.addedBy == null &&
        _accepted.contains(warning.owner)) {
      return;
    }
    // a reset is one question however many chats it shows up in
    final key = (
      warning.owner,
      warning.unverified ? null : warning.addedBy,
      warning.unverified,
    );
    if (!_pending.add(key)) return;
    _shown = _shown.then((_) async {
      try {
        await _show(warning);
      } catch (e) {
        debugPrint('[DeviceWarning] $e');
      } finally {
        _pending.remove(key);
      }
    });
  }

  Future<void> _show(GroupDeviceWarning warning) async {
    final owner = await _name(warning.owner);
    final adder = warning.addedBy == null
        ? null
        : await _name(warning.addedBy!);
    if (!mounted) return;

    if (warning.unverified) {
      final client = ref.read(ecpClientProvider);
      // the user's own devices were reset from another one, which removed
      // this one, rather than a contact's
      if (warning.owner == client.me.id) {
        await ref.read(ecpCoreHolderProvider.notifier).checkDeviceRemoved();
        return;
      }
      final person = Person.fromId(warning.owner);
      // accepted meanwhile, from a warning about another chat
      if (await _isTrusted(client, person) || !mounted) return;
      if (!await confirmDevicesChanged(context, owner)) return;
      _accepted.add(warning.owner);
      await client.groups.acceptDeviceReset(person);
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.messengerUnknownDeviceTitle),
        content: Text(
          adder == null
              ? l10n.messengerUnknownDeviceBody(owner)
              : l10n.messengerUnknownDeviceAddedBody(adder, owner),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  Future<bool> _isTrusted(EcpClient client, Person person) async {
    try {
      await client.devices.fetch(person);
      return true;
    } on EcpDeviceChainChangedException {
      return false;
    } on EcpDeviceChainException {
      return false;
    }
  }

  Future<String> _name(Uri actor) async {
    try {
      final user = await ref.read(userProvider(uidFromActorId(actor)).future);
      return user.name;
    } catch (_) {
      return uidFromActorId(actor);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
