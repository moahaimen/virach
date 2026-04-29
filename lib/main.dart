import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:racheeta/providers/app_providers.dart';      // buildAppProviders(...)
import 'package:racheeta/routing/root_decider.dart';
import 'package:racheeta/services/connectivity_check_service.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:racheeta/providers/theme_provider.dart';     // ThemeProvider for Consumer
import 'package:flutter_localizations/flutter_localizations.dart';
import 'di/dependency_ingection.dart';
import 'widgets/connectivity_snackbar.dart'; // ⬅︎ add import


late ConnectivityService connectivityService; // 👈 Global instance
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();

  // 1) Initialize Firebase
  await Firebase.initializeApp();
  await PrefsService.init();  // ✅ load once here
  // 2) iOS notification permissions (no-op on Android)
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  debugPrint('⚙️ Notification permission: ${settings.authorizationStatus}');

  // 3) Listen for FCM token refreshes
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    debugPrint('🔄 [onTokenRefresh] FCM token: $newToken');
  });

  // 4) Grab the initial FCM token
  try {
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('🎫 [getToken] FCM token: $token');
  } catch (e) {
    debugPrint('❌ Error getting FCM token: $e');
  }

  // 5) Activate Firebase App Check
  if (foundation.kDebugMode) {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );
    debugPrint("🚀 Firebase App Check activated in DEBUG mode.");
  } else {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
    );
    debugPrint("🔒 Firebase App Check activated with Play Integrity.");
  }

  // 6) Initialize timezone data
  tz.initializeTimeZones();

  // 7) Load SharedPreferences and pass it to buildAppProviders
  final prefs = await SharedPreferences.getInstance();
// ✅ Initialize global connectivity service
  connectivityService = ConnectivityService();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences? prefs;
  const MyApp({this.prefs, super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap our entire widget tree in all providers (including ThemeProvider)
    return buildAppProviders(
      prefs: prefs!,
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
          title: 'Service Provider App',
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
          // 👇 inject the SnackBar listener globally
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

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs => _prefs;
}