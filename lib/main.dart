import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:racheeta/providers/app_providers.dart';
import 'package:racheeta/providers/theme_provider.dart';
import 'package:racheeta/routing/root_decider.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'di/dependency_ingection.dart';
import 'widgets/connectivity_snackbar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  await PrefsService.init(prefs);
  await setup();
  await _initializeFirebaseServices();

  tz.initializeTimeZones();

  runApp(MyApp(prefs: prefs));
}

Future<void> _initializeFirebaseServices() async {
  await Firebase.initializeApp();

  try {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.onTokenRefresh.listen((_) {
      if (foundation.kDebugMode) {
        debugPrint('FCM token refreshed.');
      }
    });
  } catch (e) {
    if (foundation.kDebugMode) {
      debugPrint('Firebase Messaging initialization skipped: $e');
    }
  }

  try {
    if (foundation.kIsWeb) {
      return;
    }

    await FirebaseAppCheck.instance.activate(
      androidProvider: foundation.kDebugMode
          ? AndroidProvider.debug
          : AndroidProvider.playIntegrity,
      appleProvider: foundation.kDebugMode
          ? AppleProvider.debug
          : AppleProvider.appAttest,
    );
  } catch (e) {
    if (foundation.kDebugMode) {
      debugPrint('Firebase App Check initialization skipped: $e');
    }
  }
}

class MyApp extends StatelessWidget {
  final SharedPreferences? prefs;
  const MyApp({this.prefs, super.key});

  @override
  Widget build(BuildContext context) {
    final appPrefs = prefs ?? PrefsService.prefs;

    return buildAppProviders(
      prefs: appPrefs,
      child: const AppEntry(),
    );
  }
}

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Racheeta',
          themeMode: themeProvider.themeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar', '')],
          locale: const Locale('ar', ''),
          home: const RootDecider(),
          builder: (context, child) => Stack(
            children: [
              child!,
              const ConnectivitySnackBar(),
            ],
          ),
        );
      },
    );
  }
}

class PrefsService {
  static late SharedPreferences _prefs;

  static Future<void> init([SharedPreferences? prefs]) async {
    _prefs = prefs ?? await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs => _prefs;
}
