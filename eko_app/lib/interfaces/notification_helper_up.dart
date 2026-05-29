part of 'notification_helper.dart';

class UnifiedPushNotificationAdapter extends NotificationPlatformAdapter {
  const UnifiedPushNotificationAdapter();

  @override
  bool get registersDuringSetup => false;

  static const String instanceId = 'default';
  static const String _linuxDbusName = 'com.eko.network';
  static const String _linuxDefaultActionName = 'Open notification';
  static const String _androidChannelId = 'eko_unified_push';
  static const String _androidChannelName = 'Notifications';
  static final FlutterLocalNotificationsPlugin _flutterLocalNotifications =
      FlutterLocalNotificationsPlugin();
  static void Function(String?)? _onEndpoint;
  static void Function()? _onMessage;
  static NotificationPayloadHandler? _navigationHandler;
  static BuildContext? _handlerContext;
  static bool _initialized = false;
  static bool _prefsInitialized = false;
  static Completer<String?>? _tokenCompleter;
  static String? _lastSerializedEndpoint;
  static int _linuxBackgroundLaunchDepth = 0;

  static bool get _unifiedPushLinuxBackground =>
      _linuxBackgroundLaunchDepth > 0;

  static void markLinuxBackgroundLaunch() {
    _linuxBackgroundLaunchDepth++;
  }

  static void clearLinuxBackgroundLaunch() {
    if (_linuxBackgroundLaunchDepth > 0) {
      _linuxBackgroundLaunchDepth--;
    }
  }

  static Future<void> _onLocalNotificationResponse(
    NotificationResponse response,
  ) async {
    final handler = _navigationHandler;
    if (handler == null) return;
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) return;
      data = decoded.map((key, value) => MapEntry(key.toString(), value));
    } catch (_) {
      return;
    }
    final context = NotificationHelper.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;
    await handler(context, data);
    _onMessage?.call();
  }

  static bool _localNotificationsInitialized = false;
  static int _notificationId = 0;

  static Future<void> _ensureFlutterLocalNotificationsInitialized() async {
    if (_localNotificationsInitialized) return;
    const androidInit = AndroidInitializationSettings('@drawable/ic_stat_name');
    const linuxInit = LinuxInitializationSettings(
      defaultActionName: _linuxDefaultActionName,
    );
    await _flutterLocalNotifications.initialize(
      settings: InitializationSettings(
        android: platform.isAndroid ? androidInit : null,
        linux: platform.isLinux ? linuxInit : null,
      ),
      onDidReceiveNotificationResponse: (platform.isAndroid || platform.isLinux)
          ? _onLocalNotificationResponse
          : null,
    );
    if (platform.isAndroid) {
      final android = _flutterLocalNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _androidChannelId,
          _androidChannelName,
          description: 'UnifiedPush',
          importance: Importance.high,
        ),
      );
    }
    _localNotificationsInitialized = true;
  }

  static String? _serializedWebPushSubscription(PushEndpoint endpoint) {
    final url = endpoint.url;
    if (url.isEmpty) return null;
    final keys = endpoint.pubKeySet;
    final map = <String, Object?>{'endpoint': url};
    if (keys != null) {
      map['keys'] = {'p256dh': keys.pubKey, 'auth': keys.auth};
    }
    return jsonEncode(map);
  }

  static Future<void> _ensurePrefsInitialized() async {
    if (_prefsInitialized) return;
    try {
      PrefsService.instance;
      _prefsInitialized = true;
      return;
    } catch (_) {}
    await PrefsService.init();
    _prefsInitialized = true;
  }

  static Future<void> _clearStaleLinuxSavedDistributorIfNeeded() async {
    if (!platform.isLinux) return;
    final storage = UnifiedPushStorageSharedPreferences();
    final saved = await storage.distrib.get();
    if (saved == null || saved.isEmpty) return;
    Future<List<String>> listDistributors() => UnifiedPush.getDistributors();
    var distributors = await listDistributors();
    if (!distributors.contains(saved)) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      distributors = await listDistributors();
    }
    if (distributors.contains(saved)) return;
    debugPrint(
      '[UnifiedPush] linux distributor $saved absent from DBus (${distributors.length} names); clearing saved distributor',
    );
    await storage.registrations.remove(instanceId);
    await storage.distrib.remove();
    PrefsService.deviceNotificationToken = null;
    PrefsService.notificationsEnabled = false;
  }

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _ensurePrefsInitialized();
    await _clearStaleLinuxSavedDistributorIfNeeded();
    _initialized = true;
    try {
      debugPrint('[UnifiedPush] initialize start');
      await _ensureFlutterLocalNotificationsInitialized();
      final LinuxOptions? linuxOptions = platform.isLinux
          ? LinuxOptions(
              dbusName: _linuxDbusName,
              storage: UnifiedPushStorageSharedPreferences(),
              background: _unifiedPushLinuxBackground,
            )
          : null;
      await UnifiedPush.initialize(
        linuxOptions: linuxOptions,
        onNewEndpoint: (endpoint, instance) {
          if (instance != instanceId) return;
          final token = _serializedWebPushSubscription(endpoint);
          if (token != null && token == _lastSerializedEndpoint) {
            _completeToken(token);
            return;
          }
          _lastSerializedEndpoint = token;
          debugPrint(
            '[UnifiedPush] onNewEndpoint instance=$instance url=${endpoint.url}',
          );
          PrefsService.deviceNotificationToken = token;
          PrefsService.notificationsEnabled = token != null && token.isNotEmpty;
          _onEndpoint?.call(token);
          _completeToken(token);
        },
        onRegistrationFailed: (reason, instance) {
          if (instance != instanceId) return;
          _lastSerializedEndpoint = null;
          debugPrint(
            '[UnifiedPush] onRegistrationFailed instance=$instance reason=$reason',
          );
          PrefsService.deviceNotificationToken = null;
          PrefsService.notificationsEnabled = false;
          _onEndpoint?.call(null);
          _completeToken(null);
        },
        onUnregistered: (instance) {
          if (instance != instanceId) return;
          _lastSerializedEndpoint = null;
          debugPrint('[UnifiedPush] onUnregistered instance=$instance');
          PrefsService.deviceNotificationToken = null;
          PrefsService.notificationsEnabled = false;
          _onEndpoint?.call(null);
          _completeToken(null);
        },
        onMessage: (message, instance) async {
          if (instance != instanceId) return;
          debugPrint(
            '[UnifiedPush] onMessage instance=$instance contentType=${message.content.runtimeType}',
          );
          final decoded = _decodePayload(message.content);
          debugPrint(
            '[UnifiedPush] onMessage payloadKeys=${decoded.keys.join(",")}',
          );

          final title = decoded['title'] as String? ?? 'New notification';
          final body =
              decoded['body'] as String? ?? decoded['message'] as String? ?? '';

          await _ensureFlutterLocalNotificationsInitialized();
          _notificationId = (_notificationId + 1) & 0x7fffffff;
          String? payload;
          try {
            payload = jsonEncode(decoded);
          } catch (_) {
            payload = null;
          }
          final NotificationDetails details;
          if (platform.isAndroid) {
            details = const NotificationDetails(
              android: AndroidNotificationDetails(
                _androidChannelId,
                _androidChannelName,
                importance: Importance.high,
                priority: Priority.high,
              ),
            );
          } else if (platform.isLinux) {
            details = NotificationDetails(
              linux: LinuxNotificationDetails(
                defaultActionName: _linuxDefaultActionName,
              ),
            );
          } else {
            details = const NotificationDetails();
          }
          try {
            await _flutterLocalNotifications.show(
              id: _notificationId,
              title: title,
              body: body,
              payload: payload,
              notificationDetails: details,
            );
          } catch (e, st) {
            debugPrint('[UnifiedPush] local notification show failed: $e $st');
          }

          _onMessage?.call();
        },
        onTempUnavailable: (instance) {
          if (instance != instanceId) return;
          debugPrint('[UnifiedPush] onTempUnavailable instance=$instance');
        },
      );
      debugPrint('[UnifiedPush] initialize complete');
    } catch (_) {
      _initialized = false;
      debugPrint('[UnifiedPush] initialize failed');
      rethrow;
    }
  }

  static Map<String, dynamic> _decodePayload(dynamic content) {
    if (content == null) return {};
    String payload;
    if (content is Uint8List) {
      if (content.isEmpty) return {};
      debugPrint(
        '[UnifiedPush] decode payload from bytes length=${content.length}',
      );
      payload = utf8.decode(content);
    } else if (content is String) {
      if (content.isEmpty) return {};
      debugPrint(
        '[UnifiedPush] decode payload from string length=${content.length}',
      );
      payload = content;
    } else {
      debugPrint(
        '[UnifiedPush] decode payload unsupported type=${content.runtimeType}',
      );
      return {};
    }
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {}
    if (payload.contains('=')) {
      try {
        final form = _decodeFormStylePayload(payload);
        if (form.isNotEmpty) return form;
      } catch (_) {}
    }
    debugPrint('[UnifiedPush] decode payload failed');
    return {};
  }

  static Map<String, dynamic> _decodeFormStylePayload(String payload) {
    final decoded = <String, dynamic>{};
    for (final part in payload.split('&')) {
      final idx = part.indexOf('=');
      if (idx <= 0) continue;
      final key = Uri.decodeComponent(part.substring(0, idx));
      final value = Uri.decodeComponent(part.substring(idx + 1));
      decoded[key] = value;
    }
    return decoded;
  }

  static void _completeToken(String? token) {
    final completer = _tokenCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(token);
    }
  }

  static Future<String?> _pickDistributor(BuildContext context) async {
    final distributors = await UnifiedPush.getDistributors();
    debugPrint('[UnifiedPush] distributors count=${distributors.length}');
    if (distributors.isEmpty) return null;
    if (!context.mounted) return null;
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(dialogContext).colorScheme.outlineVariant,
          title: const Text('Select a distributor'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: distributors.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final distributor = distributors[index];
                final name = distributor.split('.').last;
                return ListTile(
                  title: Text(name),
                  subtitle: Text(distributor),
                  onTap: () => context.pop(distributor),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Future<void> initialize() async {
    await _ensureInitialized();
  }

  @override
  Future<void> requestPermissions() async {
    await _ensureInitialized();
    debugPrint('[UnifiedPush] requestPermissions start');
    if (platform.isAndroid) {
      final notification = await Permission.notification.request();
      debugPrint(
        '[UnifiedPush] notification permission=${notification.toString()}',
      );
    }
    if (platform.isAndroid || platform.isLinux) {
      await WidgetsBinding.instance.endOfFrame;
      debugPrint('[UnifiedPush] requestPermissions after endOfFrame');
    }
    var success = await UnifiedPush.tryUseCurrentOrDefaultDistributor();
    debugPrint(
      '[UnifiedPush] tryUseCurrentOrDefaultDistributor success=$success',
    );
    if (!success && platform.isAndroid) {
      await WidgetsBinding.instance.endOfFrame;
      success = await UnifiedPush.tryUseCurrentOrDefaultDistributor();
      debugPrint(
        '[UnifiedPush] tryUseCurrentOrDefaultDistributor retry=$success',
      );
    }
    if (success) {
      final d = await UnifiedPush.getDistributor();
      debugPrint('[UnifiedPush] active distributor=$d');
      return;
    }
    final context =
        _handlerContext ?? NotificationHelper.navigatorKey.currentContext;
    if (context == null || !context.mounted) {
      debugPrint(
        '[UnifiedPush] no context for distributor picker (handler=${_handlerContext != null} nav=${NotificationHelper.navigatorKey.currentContext != null})',
      );
      return;
    }
    final choice = await _pickDistributor(context);
    if (choice == null) {
      debugPrint('[UnifiedPush] distributor picker dismissed or empty list');
      return;
    }
    debugPrint('[UnifiedPush] saveDistributor choice=$choice');
    await UnifiedPush.saveDistributor(choice);
  }

  @override
  Future<void> registerDevice() async {
    await _ensureInitialized();
    if (_tokenCompleter == null || _tokenCompleter!.isCompleted) {
      _tokenCompleter = Completer<String?>();
    }
    debugPrint('[UnifiedPush] registerDevice instance=$instanceId');
    await UnifiedPush.register(instance: instanceId, vapid: ac.vapidPublicKey);
  }

  @override
  Future<String?> getDeviceToken({bool forBackendSync = false}) async {
    await _ensureInitialized();
    final existing = PrefsService.deviceNotificationToken;
    debugPrint(
      '[UnifiedPush] getDeviceToken existing=${existing?.isNotEmpty == true} '
      'forBackendSync=$forBackendSync',
    );
    if (!forBackendSync && existing != null && existing.isNotEmpty) {
      return existing;
    }
    _tokenCompleter = Completer<String?>();
    await registerDevice();
    try {
      final token = await _tokenCompleter!.future.timeout(
        const Duration(seconds: 8),
      );
      debugPrint(
        '[UnifiedPush] getDeviceToken resolved=${token?.isNotEmpty == true}',
      );
      if (token != null && token.isNotEmpty) {
        PrefsService.deviceNotificationToken = token;
      }
      return token;
    } on TimeoutException {
      debugPrint('[UnifiedPush] getDeviceToken timeout');
      return null;
    }
  }

  @override
  void setHandlers(
    BuildContext context,
    void Function() callback,
    NotificationPayloadHandler handler,
  ) {
    _handlerContext = context;
    _onMessage = callback;
    _navigationHandler = handler;
    _onEndpoint = (endpoint) {
      debugPrint(
        '[UnifiedPush] onEndpoint handler endpoint=${endpoint?.isNotEmpty == true}',
      );
      PrefsService.deviceNotificationToken = endpoint;
      PrefsService.notificationsEnabled =
          endpoint != null && endpoint.isNotEmpty;
    };
  }
}
