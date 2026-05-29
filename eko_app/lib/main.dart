import 'dart:ui';

import 'package:eko_app/interfaces/notification_helper.dart';
import 'package:eko_app/utilities/api_constants.dart' as ac;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:eko_app/providers/theme_provider.dart';
import 'package:eko_app/utilities/logo_service.dart';
import 'package:eko_app/utilities/provider_debugger.dart';
import 'package:eko_app/utilities/shared_pref_service.dart';
import 'package:eko_app/utilities/supabase_session_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/widgets/scaffolds/check_version.dart';
import 'utilities/router.dart';
import 'package:eko_app/utilities/platform.dart' as platform;
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> _checkFirstInstall() async {
  if (!PrefsService.notFirstInstall) {
    if (!kDebugMode && Supabase.instance.client.auth.currentSession != null) {
      await Supabase.instance.client.auth.signOut();
    }
    await PrefsService.markNotFirstInstall();
  }
}

Future<void> _initSupabase() async {
  final projectRef = Uri.parse(ac.supabaseUrl).host.split('.').first;
  await Supabase.initialize(
    url: ac.supabaseUrl,
    anonKey: ac.supabaseKey,
    authOptions: platform.isLinux
        ? FlutterAuthClientOptions(
            authFlowType: AuthFlowType.implicit,
            localStorage: ReliableSupabaseSessionStorage(
              persistSessionKey: 'sb-$projectRef-auth-token',
            ),
          )
        : FlutterAuthClientOptions(authFlowType: AuthFlowType.implicit),
  );
}

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb &&
      (platform.isAndroid || platform.isLinux) &&
      args.contains('--unifiedpush-bg')) {
    await PrefsService.init();
    await NotificationHelper.bootstrapUnifiedPushBackground(args);
    return;
  }
  usePathUrlStrategy();
  await Future.wait([PrefsService.init(), _initSupabase()]);
  // setupLocator();
  //protected/dependent services
  await Future.wait([_checkFirstInstall(), LogoService.init()]);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final List<ProviderObserver>? observers = kDebugMode
      ? [ProviderDebuggerObserver()]
      : null;
  runApp(ProviderScope(observers: observers, child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(colorThemeProvider);

    return OverlaySupport(
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        title: 'eko',
        debugShowCheckedModeBanner: false,
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: PointerDeviceKind.values.toSet(),
        ),
        theme: ThemeData(
          fontFamily: platform.isLinux ? 'Inter' : null,
          fontFamilyFallback: platform.isLinux ? ['NotoEmoji'] : null,
          colorScheme: theme,
          useMaterial3: true,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          tabBarTheme: TabBarThemeData(
            overlayColor: WidgetStatePropertyAll(Colors.transparent),
          ),
        ),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('es'), // Spanish
          Locale('hi'), // Hindi
          Locale('id'), // Indonesian
        ],
        builder: (context, child) => CheckVersion(child: child),
        routerConfig: ref.watch(goRouterProvider),
      ),
    );
  }
}
