import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart' as prov;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled_app/models/firebase_helper.dart';
import 'package:untitled_app/models/notification_service.dart';
import 'package:untitled_app/models/version_control.dart';
import 'package:untitled_app/providers/post_pool_provider.dart';
import 'package:untitled_app/providers/user_pool_provider.dart';
import 'package:untitled_app/utilities/provider_debugger.dart';
import 'utilities/themes/dark_theme_provider.dart';
import 'utilities/themes/dark_theme_styles.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:untitled_app/localization/generated/app_localizations.dart';
import 'utilities/router.dart';
import 'utilities/locator.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import '../models/shared_pref_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/current_user.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:untitled_app/firebase_options.dart';
// import 'package:untitled_app/utilities/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> _setupAppCheck() async {
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider(dotenv.env['RE_CAPTCHA']!),
    androidProvider:
        kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
    appleProvider: kReleaseMode ? AppleProvider.appAttest : AppleProvider.debug,
  );
}

Future<void> _checkFirstInstall() async {
  if ((await getBool('NOT_FIRST_INSTALL')) == null) {
    if (FirebaseAuth.instance.currentUser != null) {
      FirebaseAuth.instance.signOut();
    }
    setBool('NOT_FIRST_INSTALL', true);
  } else if (FirebaseAuth.instance.currentUser != null) {
    await locator<CurrentUser>().readCurrentUserData();
  }
}

Future<void> _setUpOtherNotification() async {
  if (!kIsWeb) await NotificationService.initializeNotification();
}

Future<void> _buildVersion() async {
  if (!kIsWeb) await locator<Version>().init();
}

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  //init
  await dotenv.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseDatabase.instance
      .setPersistenceEnabled(false); // FIXME doesnt seem to work :(

  //setup appcheck and non-protected services
  await Future.wait([
    _setupAppCheck(),
  ]);
  // //
  setupLocator();
  // //protected/dependent services
  await Future.wait([
    _checkFirstInstall(),
    _setUpOtherNotification(),
    _buildVersion(),
    FirebaseHelper.setupNotifications(),
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true)
  ]);

  if (kDebugMode) {
    runApp(ProviderScope(observers: [
      ProviderDebuggerObserver(),
    ], child: const MyApp()));
  } else {
    ProviderScope(child: const MyApp());
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(postPoolProvider);
    ref.watch(userPoolProvider);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        return prov.MultiProvider(
          providers: [
            prov.ChangeNotifierProvider(
                create: (context) => DarkThemeProvider()),
          ],
          builder: (context, child) {
            final themeChangeProvider =
                prov.Provider.of<DarkThemeProvider>(context);
            return OverlaySupport(
              child: MaterialApp.router(
                title: 'Eko',
                debugShowCheckedModeBanner: false,
                theme: Styles.themeData(themeChangeProvider.darkTheme, context),
                themeMode: ThemeMode.dark,
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
          },
        );
      },
    );
  }
}
