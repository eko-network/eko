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

    return _initAndOpenCore(session);
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

    try {
      debugPrint('[EcpCore] Registering device');
      await _initAndOpenCore(session);
      if (_core == null) {
        throw StateError('ECP core not initialized');
      }

      final (credential, keyPackages) = await _core!.createIdentity();
      debugPrint('[EcpCore] calling RPC');
      await supabase.rpc(
        'register_device',
        params: {
          'p_did': DeviceUidService.getOrCreate(),
          'p_signer_public_key': base64Encode(credential.signerPublicKey),
          'p_key_packages': keyPackages
              .map((it) => base64Encode(it.keyPackageBytes))
              .toList(),
        },
      );
      final refreshed = await supabase.auth.refreshSession();
      final device = refreshed.session != null
          ? DeviceModel.fromSession(refreshed.session!)
          : DeviceModel.idle();
      if (device.dat == null && device.did != null) {
        await sendApprovalRequest();
      }

      state = AsyncValue.data(_core!);
    } catch (e, st) {
      debugPrint('[EcpCore] registerDevice error: $e\n$st');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendApprovalRequest() async {
    final core = _core ?? state.value;
    if (core == null) {
      throw StateError('ECP core not initialized');
    }

    final did = ref.read(authProvider).value?.device?.did;
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
      final handler = MessageHandler(
        core: core,
        client: client,
        activitySender: ActivitySender(
          client: client,
          did: DeviceUidService.getOrCreate(),
          core: core,
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
