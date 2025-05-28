import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:untitled_app/models/notification_helper.dart';
import 'package:untitled_app/models/version_control.dart';
import 'package:untitled_app/providers/post_pool_provider.dart';
import 'package:untitled_app/providers/theme_provider.dart';
import 'package:untitled_app/providers/user_pool_provider.dart';
import 'package:untitled_app/utilities/logo_service.dart';
import 'package:untitled_app/utilities/provider_debugger.dart';
import 'package:untitled_app/utilities/shared_pref_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'utilities/router.dart';
import 'utilities/locator.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import '../models/shared_pref_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:untitled_app/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> _checkFirstInstall() async {
  if ((PrefsService.instance.getBool('NOT_FIRST_INSTALL')) == null) {
    if (FirebaseAuth.instance.currentUser != null) {
      FirebaseAuth.instance.signOut();
    }
    setBool('NOT_FIRST_INSTALL', true);
  }
}

Future<void> _buildVersion() async {
  if (!kIsWeb) await locator<Version>().init();
}

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  //init
  await Future.wait([
    PrefsService.init(),
    dotenv.load(),
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    )
  ]);
  setupLocator();
  //protected/dependent services
  await Future.wait([
    _checkFirstInstall(),
    _buildVersion(),
    LogoService.init(),
    NotificationHelper.setupNotifications(),
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true)
  ]);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final List<ProviderObserver>? observers =
      kDebugMode ? [ProviderDebuggerObserver()] : null;
  runApp(ProviderScope(observers: observers, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(colorThemeProvider);
    ref.watch(postPoolProvider);
    ref.watch(userPoolProvider);
    return OverlaySupport(
      child: MaterialApp.router(
        title: 'Eko',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: theme,
          useMaterial3: true,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
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
        ],
        routerConfig: goRouter,
      ),
    );
  }
}
