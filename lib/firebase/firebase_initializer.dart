import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

class FirebaseInitializer {
  static Future<void> initialize() async {
    await Firebase.initializeApp();

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('⚙️ Notification permission: \${settings.authorizationStatus}');

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 [onTokenRefresh] FCM token: \$newToken');
    });

    try {
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('🎫 [getToken] FCM token: \$token');
    } catch (e) {
      debugPrint('❌ Error getting FCM token: \$e');
    }

    if (kDebugMode) {
      await FirebaseAppCheck.instance.activate(androidProvider: AndroidProvider.debug);
    } else {
      await FirebaseAppCheck.instance.activate(androidProvider: AndroidProvider.playIntegrity);
    }

    tz.initializeTimeZones();
  }
}

