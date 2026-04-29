import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import '../utitlites/notification_cache.dart'; // Ensure the path is correct

const String _fcmServerKey = "YOUR_SERVER_KEY_HERE";
const String _fcmUrl = "https://fcm.googleapis.com/fcm/send";

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
  FlutterLocalNotificationsPlugin();

  String? _cachedToken;
  String? get token => _cachedToken;

  void Function(Map<String, dynamic>)? onMessageOpenedApp;

  Future<void> init() async {
    try {
      // Check for APNs token on iOS
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('📵 No APNs token available (probably simulator)');
          return; // Skip setup
        }
      }

      // Request notification permissions.
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint('🚫 Notification permission denied');
        return;
      }

      // Retrieve FCM token.
      _cachedToken = await _messaging.getToken();
      debugPrint('📲 FCM Token: $_cachedToken');
      await _persistTokenLocally(_cachedToken);

      // Create Android notification channel.
      const channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'Used for foreground notifications',
        importance: Importance.high,
      );
      await _local
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Initialize local notifications.
      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _local.initialize(initSettings,
          onDidReceiveNotificationResponse: (resp) {
            onMessageOpenedApp
                ?.call(resp.payload != null ? {'payload': resp.payload} : {});
          });

      // Setup FCM message listeners.
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen((m) {
        onMessageOpenedApp?.call(m.data);
      });
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint('🚨 Firebase Messaging Initialization Error: $e');
    }
  }

  Future<void> showLocal({
    required String title,
    required String body,
    String? payload,
    bool alsoCache = false,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _local.show(0, title, body, details, payload: payload);

    if (alsoCache) {
      debugPrint("Caching local notification: title=$title, body=$body");
      await NotificationCache.add(LocalNotification(
        id: const Uuid().v4(),
        title: title,
        body: body,
        timestamp: DateTime.now().toIso8601String(),
      ));
    }
  }

  Future<void> sendPush({
    required String to,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final payload = {
        "to": to,
        "notification": {
          "title": title,
          "body": body,
        },
        "data": data ?? {},
      };
      final dio = Dio();
      await dio.post(
        _fcmUrl,
        data: jsonEncode(payload),
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "key=$_fcmServerKey",
          },
        ),
      );
      debugPrint("Push notification sent successfully.");
    } catch (e) {
      debugPrint('❌ sendPush error: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage m) async {
    final notification = m.notification;
    if (notification == null) return;

    String title = notification.title ?? m.data['title'] ?? '';
    String body = notification.body ?? m.data['body'] ?? '';

    if (title.isEmpty && body.isEmpty) {
      debugPrint("No valid notification data found.");
      return;
    }
    debugPrint("Foreground notification: title = $title, body = $body");

    await showLocal(title: title, body: body);
    await NotificationCache.add(LocalNotification(
      id: m.messageId ?? const Uuid().v4(),
      title: title,
      body: body,
      timestamp: DateTime.now().toIso8601String(),
    ));
  }

  Future<void> _persistTokenLocally(String? t) async {
    if (t == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', t);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage m) async {
  await Firebase.initializeApp();
  debugPrint("Background message received: \${m.data}");
  final notification = m.notification;
  if (notification == null) return;

  String title = notification.title ?? m.data['title'] ?? '';
  String body = notification.body ?? m.data['body'] ?? '';

  if (title.isEmpty && body.isEmpty) {
    debugPrint("Background message missing title and body.");
    return;
  }
  debugPrint("Background notification: title = $title, body = $body");

  await NotificationCache.add(LocalNotification(
    id: m.messageId ?? const Uuid().v4(),
    title: title,
    body: body,
    timestamp: DateTime.now().toIso8601String(),
  ));
}