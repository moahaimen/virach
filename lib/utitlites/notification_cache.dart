// notification_cache.dart
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotification {
  LocalNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp, // ISO8601 string
    this.isRead = false,
  });

  String id; // e.g., a UUID
  String title;
  String body;
  String timestamp;
  bool isRead;

  factory LocalNotification.fromJson(Map<String, dynamic> json) =>
      LocalNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        timestamp: json['timestamp'] as String,
        isRead: json['isRead'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp,
        'isRead': isRead,
      };
}

class NotificationCache {
  static const String _key = 'cached_notifications';
  static const int _max = 10;

  // Broadcast stream (if you later want real‑time updates)
  static final _controller =
      StreamController<List<LocalNotification>>.broadcast();
  static Stream<List<LocalNotification>> get stream => _controller.stream;

  static Future<List<LocalNotification>> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    final notifications = decoded
        .map((e) =>
            LocalNotification.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return notifications;
  }

  static Future<void> write(List<LocalNotification> list) async {
    final prefs = await SharedPreferences.getInstance();
    // Sort descending so that the newest come first.
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (list.length > _max) list.removeRange(_max, list.length);
    await prefs.setString(
        _key, jsonEncode(list.map((e) => e.toJson()).toList()));
    _controller.add(list);
  }

  /// Convenience method to add a new notification.
  static Future<void> add(LocalNotification n) async {
    final list = await read();
    list.insert(0, n);
    await write(list);
  }
}
