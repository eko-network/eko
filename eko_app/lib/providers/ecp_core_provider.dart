import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ecp/ecp.dart';
import 'package:eko_app/database/database.dart';
import 'package:eko_app/database/storage.dart';
import 'package:eko_app/messenger/ecp_helpers.dart';
import 'package:eko_app/messenger/utilities/authenticated_http_client.dart';
import 'package:eko_app/providers/auth_provider.dart';
import 'package:eko_app/types/device.dart';
import 'package:eko_app/utilities/device_uid_service.dart';
import 'package:eko_app/utilities/ecp_db_path.dart';
import 'package:eko_app/utilities/platform.dart' as platform;
import 'package:eko_app/utilities/shared_pref_service.dart';
import 'package:eko_app/utilities/supabase_ref.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part '../generated/providers/ecp_core_provider.g.dart';

@Riverpod(keepAlive: true)
class EcpCoreHolder extends _$EcpCoreHolder {
  EcpCore? _core;
  bool _refillingKeyPackages = false;
  bool _checkingRemoved = false;

  /// Below this many fresh key packages on the server the device uploads more.
  static const _minFreshKeyPackages = 10;

  @override
  Future<EcpCore?> build() async {
    ref.onDispose(() {
      _core?.close();
    });

    ref.listen(authProvider, (previous, next) {
      if (next.isLoading) return;
      final prevUid = previous?.value?.uid;
      final nextUid = next.value?.uid;
      if (nextUid == null) {
        _cleanAfterSignOut();
        return;
      }
      if (prevUid != null && prevUid != nextUid) {
        _cleanAfterSignOut();
        return;
      }
      // a refreshed token leaves out a device that was removed. A pending
      // device also loses it while resetting devices, so only an approved one
      // is checked
      if (previous?.value?.device?.dat != null &&
          next.value?.device?.did == null) {
        unawaited(checkDeviceRemoved());
      }
    });

    final session = supabase.auth.currentSession;
    if (session == null || platform.isWeb) {
      return null;
    }

    final auth = ref.watch(authProvider);
    if (auth.isLoading) {
      if (_core != null) return _core;
      return null;
    }

    final did = auth.value?.device?.did;
    if (did == null || did.isEmpty) {
      return null;
    }

    final core = await _initAndOpenCore(session);
    unawaited(_refillKeyPackages(core, did));
    return core;
  }

  /// Uploads new key packages once this device has few fresh ones left on the
  /// server, see key_package_status in the Supabase migration.
  Future<void> _refillKeyPackages(EcpCore core, String did) async {
    if (_refillingKeyPackages) return;
    _refillingKeyPackages = true;
    try {
      final status =
          await supabase.rpc('key_package_status', params: {'p_did': did})
              as Map<String, dynamic>;
      if ((status['fresh'] as int) >= _minFreshKeyPackages &&
          status['freshLastResort'] == true) {
        return;
      }
      debugPrint('[EcpCore] Refilling key packages ($status)');
      final batch = await core.createKeyPackages();
      await supabase.rpc(
        'add_key_packages',
        params: {
          'p_did': did,
          'p_key_packages': batch.keyPackages
              .map((it) => base64Encode(it.keyPackageBytes))
              .toList(),
          'p_last_resort_key_package': base64Encode(
            batch.lastResort.keyPackageBytes,
          ),
        },
      );
    } catch (e, st) {
      debugPrint('[EcpCore] key package refill error: $e\n$st');
    } finally {
      _refillingKeyPackages = false;
    }
  }

  Future<EcpCore> _initAndOpenCore(Session session) async {
    final u = session.user;
    if (_core == null) {
      debugPrint('[EcpCore] Initializing core');
      final storage = AppStorage(db);
      final mlsDbDir = await getDbPath();
      final mlsDbDirEntity = Directory(mlsDbDir);
      if (!await mlsDbDirEntity.exists()) {
        await mlsDbDirEntity.create(recursive: true);
      }
      final mlsDbFile = File(p.join(mlsDbDir, 'mls.db'));

      try {
        final existingConfig = await storage.mlsEngineConfigStore.getConfig();
        if (existingConfig != null && existingConfig.dbPath != mlsDbFile.path) {
          debugPrint(
            '[EcpCore] Updating stale mls.db path: ${existingConfig.dbPath} -> ${mlsDbFile.path}',
          );
          final oldFile = File(existingConfig.dbPath);
          if (await oldFile.exists()) {
            try {
              if (await mlsDbFile.exists()) {
                await mlsDbFile.delete();
              }
              await mlsDbFile.writeAsBytes(await oldFile.readAsBytes());
              debugPrint('[EcpCore] Migrated mls.db to new location');
            } catch (e) {
              debugPrint('[EcpCore] Failed to migrate mls.db: $e');
            }
          }
          await storage.mlsEngineConfigStore.saveConfig(
            MlsEngineConfig(
              dbPath: mlsDbFile.path,
              encryptionKey: existingConfig.encryptionKey,
            ),
          );
        }
      } catch (e) {
        debugPrint('[EcpCore] Error checking/updating stale mls.db path: $e');
      }

      final engineConfig = await MlsEngineConfig.fromPath(mlsDbFile, storage);

      // for ios add key to storage so NotificationService can read it securely
      if (platform.isIOS) {
        const secureStorage = FlutterSecureStorage(
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
            synchronizable: false,
            groupId: 'group.com.example.untitledApp',
          ),
        );
        await secureStorage.write(
          key: 'mls_encryption_key',
          value: base64Encode(engineConfig.encryptionKey),
        );
      }

      _core = EcpCore(
        storage: storage,
        identity: EkoPerson.fromUid(u.id),
        engineConfig: engineConfig,
      );
    }

    assert(_core != null, 'core cannot be null');
    try {
      await _core!.open();
    } catch (e) {
      if (e.toString().contains('Encryption key verification failed')) {
        _core = null;
        return _initAndOpenCore(session);
      }
      rethrow;
    }

    debugPrint('[EcpCore] Core is open');
    return _core!;
  }

  Future<void> registerDevice() async {
    final session = supabase.auth.currentSession;
    if (session == null || platform.isWeb) return;

    final authDevice = ref.read(authProvider).value?.device;
    if (authDevice?.isRegistered == true) {
      if (state.value == null) {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() => _initAndOpenCore(session));
      }
      return;
    }

    state = const AsyncValue.loading();
    ref.read(deviceRemovedNoticeProvider.notifier).show(false);

    try {
      debugPrint('[EcpCore] Registering device');
      await _initAndOpenCore(session);
      if (_core == null) {
        throw StateError('ECP core not initialized');
      }

      final (credential, keyPackages) = await _core!.createIdentity();
      final did = DeviceUidService.getOrCreate();
      // only used when the server trusts this device on first use
      final genesis = await DeviceChainEntry.genesis(
        actor: _core!.identity.id,
        did: did,
        credential: credential,
      );
      debugPrint('[EcpCore] calling RPC');
      await supabase.rpc(
        'register_device',
        params: {
          'p_did': did,
          'p_signer_public_key': base64Encode(credential.signerPublicKey),
          'p_key_packages': keyPackages.keyPackages
              .map((it) => base64Encode(it.keyPackageBytes))
              .toList(),
          'p_last_resort_key_package': base64Encode(
            keyPackages.lastResort.keyPackageBytes,
          ),
          'p_chain_entry': genesis.toJson(),
          'p_chain_hash': base64Encode(genesis.hash),
        },
      );
      final refreshed = await supabase.auth.refreshSession();
      final device = refreshed.session != null
          ? DeviceModel.fromSession(refreshed.session!)
          : DeviceModel.idle();
      if (device.dat == null && device.did != null) {
        // authProvider hasn't seen the refreshed session yet
        await sendApprovalRequest(did: device.did);
      }

      state = AsyncValue.data(_core!);
    } catch (e, st) {
      debugPrint('[EcpCore] registerDevice error: $e\n$st');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendApprovalRequest({String? did}) async {
    final core = _core ?? state.value;
    if (core == null) {
      throw StateError('ECP core not initialized');
    }

    did ??= ref.read(authProvider).value?.device?.did;
    if (did == null || did.isEmpty) {
      throw StateError('Device id not available');
    }

    final credential = await AppStorage(db).mlsCredentialStore.getCredential();
    if (credential == null) {
      throw StateError('MLS credential not available');
    }

    final client = AuthenticatedClient(
      () => supabase.auth.currentSession?.accessToken,
    );

    try {
      final activitySender = ActivitySender(
        client: client,
        did: DeviceUidService.getOrCreate(),
        core: core,
      );
      final handler = MessageHandler(
        core: core,
        client: client,
        activitySender: activitySender,
        groups: GroupManager(
          core: core,
          activitySender: activitySender,
          devices: DeviceManager(core: core, activitySender: activitySender),
        ),
      );
      await handler.sendApprovalRequest(
        publicKey: credential.signerPublicKey,
        did: did,
      );
    } finally {
      client.close();
    }
  }

  /// Emails the user the one time code [resetDevices] needs.
  Future<void> sendResetCode() async {
    final email = supabase.auth.currentUser?.email;
    if (email == null) throw StateError('Account has no email');
    await supabase.auth.signInWithOtp(email: email, shouldCreateUser: false);
  }

  /// Makes this pending device the user's only one, for when every approved
  /// device is lost. Confirming the emailed [code] signs in again, then the
  /// user's devices are replaced by this one with a new device chain, see
  /// reset_devices in the Supabase migration. Contacts are warned about it.
  Future<void> resetDevices(String code) async {
    final core = _core;
    final email = supabase.auth.currentUser?.email;
    final credential = await AppStorage(db).mlsCredentialStore.getCredential();
    if (core == null || email == null || credential == null) {
      throw StateError('Device is not registered');
    }

    // the new session has no device yet, which rebuilds this provider and
    // closes the core, so everything that needs it comes first
    final did = DeviceUidService.getOrCreate();
    final keyPackages = await core.createKeyPackages();
    final genesis = await DeviceChainEntry.genesis(
      actor: core.identity.id,
      did: did,
      credential: credential,
    );

    await supabase.auth.verifyOTP(
      type: OtpType.email,
      email: email,
      token: code,
    );
    await supabase.rpc(
      'reset_devices',
      params: {
        'p_did': did,
        'p_signer_public_key': base64Encode(credential.signerPublicKey),
        'p_key_packages': keyPackages.keyPackages
            .map((it) => base64Encode(it.keyPackageBytes))
            .toList(),
        'p_last_resort_key_package': base64Encode(
          keyPackages.lastResort.keyPackageBytes,
        ),
        'p_chain_entry': genesis.toJson(),
        'p_chain_hash': base64Encode(genesis.hash),
      },
    );
    await supabase.auth.refreshSession();
  }

  /// Checks whether this device was removed from the user's account, by
  /// another of their devices or a device reset on one, and if so wipes its
  /// messenger data and drops the device from the session, which shows
  /// messenger setup again. Its token keeps saying it is approved until it
  /// expires, so this runs on hints: the messenger server turning it away,
  /// the device leaving the token, or the user's own devices being reset.
  Future<bool> checkDeviceRemoved() async {
    // gone once wiped, so later hints about the same removal do nothing
    final did = PrefsService.deviceUid;
    if (did == null || _checkingRemoved) return false;
    _checkingRemoved = true;
    try {
      // row level security shows only the user's own devices
      final rows = await supabase.from('devices').select('id').eq('id', did);
      if (rows.isNotEmpty) return false;
      debugPrint('[EcpCore] Device $did was removed, wiping messenger data');
      ref.read(deviceRemovedNoticeProvider.notifier).show(true);
      // the refreshed token has no device, so nothing rebuilds the core after
      // the wipe
      await supabase.auth.refreshSession();
      await _cleanAfterSignOut();
      return true;
    } catch (e, st) {
      debugPrint('[EcpCore] checkDeviceRemoved error: $e\n$st');
      return false;
    } finally {
      _checkingRemoved = false;
    }
  }

  Future<void> _cleanAfterSignOut() async {
    await AppStorage(db).clear();
    final core = _core;
    _core = null;
    if (core != null) {
      await core.close();
    }
    DeviceUidService.remove();
    ref.invalidateSelf();
  }
}

/// Whether messenger setup should say this device was removed from the
/// user's account, see [EcpCoreHolder.checkDeviceRemoved].
@Riverpod(keepAlive: true)
class DeviceRemovedNotice extends _$DeviceRemovedNotice {
  @override
  bool build() => false;

  void show(bool value) => state = value;
}
