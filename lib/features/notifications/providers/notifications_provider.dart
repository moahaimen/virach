// lib/features/notifications/providers/notifications_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../model/notification_model.dart';
import '../services/api_client.dart';
import '../../../utitlites/notification_cache.dart'; // keep path if correct

/// Helper - convert backend model → cached local model
extension BackendToLocal on NoticationsModel {
  LocalNotification toLocal() => LocalNotification(
    id: id,
    title: notificationText,
    body: notificationText,
    isRead: isRead,
    timestamp: createDate.toIso8601String(),
  );
}

class NotificationsRetroDisplayGetProvider with ChangeNotifier {
  late final Dio _dio;
  late final ApiClient _apiClient;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  List<NoticationsModel> _notifications = [];

  NotificationsRetroDisplayGetProvider(String token) {
    _dio = Dio()..options.headers['Authorization'] = 'JWT $token';
    _apiClient = ApiClient(_dio);
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'JWT $token';
  }

  List<NoticationsModel> get notifications => _notifications;

  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  Future<List<NoticationsModel>> fetchNotifications(String userId) async {
    debugPrint('🔔 [fetchNotifications] called with userId: $userId');
    debugPrint('    ↳ Authorization header: ${_dio.options.headers['Authorization']}');

    try {
      final raw = await _apiClient.getNotificationsByUserId(userId);
      debugPrint('🔔 [fetchNotifications] raw JSON (${raw.length} items): $raw');

      _notifications = raw
          .map((e) {
        debugPrint('    ↳ parsing: $e');
        return NoticationsModel.fromJson(e as Map<String, dynamic>);
      })
          .toList()
        ..sort((a, b) => b.createDate.compareTo(a.createDate));

      debugPrint('🔔 [fetchNotifications] parsed notifications count: ${_notifications.length}');
      notifyListeners();
      return _notifications;
    } catch (e, st) {
      debugPrint('❌ [fetchNotifications] error: $e\n$st');
      rethrow;
    }
  }

  Future<List<NoticationsModel>> fetchLatest15(String userId) async {
    final all = await fetchNotifications(userId);
    final slice = all.length > 15 ? all.sublist(0, 15) : all;
    _notifications = slice;
    notifyListeners();
    return _notifications;
  }

  Future<int> fetchNotificationsCount(String userId) async {
    debugPrint('🔔 [fetchNotificationsCount] called for $userId');
    try {
      final cnt = await _apiClient.getNotificationsCount(userId);
      debugPrint('🔔 [fetchNotificationsCount] backend count = $cnt');
      return cnt;
    } catch (e, st) {
      debugPrint('❌ [fetchNotificationsCount] error: $e\n$st');
      return 0;
    }
  }

  Future<void> markAsRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx == -1) return;

    try {
      await _apiClient.patchNotification(id, {'is_read': true});
    } catch (e) {
      debugPrint('[markAsRead] PATCH failed: $e');
      // continue to update locally anyway
    }

    _notifications[idx] = _notifications[idx].markRead();
    notifyListeners();
  }

  /// NEW: mark a notification as *unread*
  Future<void> markAsUnread(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx == -1) return;

    try {
      await _apiClient.patchNotification(id, {'is_read': false});
    } catch (e) {
      debugPrint('[markAsUnread] PATCH failed: $e');
      // continue to update locally anyway
    }

    _notifications[idx] = _notifications[idx].markUnread();
    notifyListeners();
  }

  /// Optional convenience: toggle read/unread (if `to` is null it flips)
  Future<void> toggleRead(String id, {bool? to}) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx == -1) return;

    final target = to ?? !_notifications[idx].isRead;
    try {
      await _apiClient.patchNotification(id, {'is_read': target});
    } catch (e) {
      debugPrint('[toggleRead] PATCH failed: $e');
    }

    _notifications[idx] =
    target ? _notifications[idx].markRead() : _notifications[idx].markUnread();
    notifyListeners();
  }

  Future<NoticationsModel?> createNotification({
    required String user,
    required String notificationText,
    bool isRead = false,
    String? createUser,
    String? updateUser,
    Map<String, dynamic>? data,
  }) async {
    final payload = <String, dynamic>{
      'user': user,
      'notification_text': notificationText,
      'is_read': isRead,
      'create_date': DateTime.now().toIso8601String(),
      'update_date': DateTime.now().toIso8601String(),
      'create_user': createUser,
      'update_user': updateUser,
    };
    if (data != null) payload['data'] = data;

    debugPrint('🔔 [createNotification] ▶ payload: $payload');
    try {
      final result = await _apiClient.createNotifications(payload);

      // Be defensive about return type
      final NoticationsModel model = switch (result) {
        NoticationsModel m => m,
        Map<String, dynamic> m => NoticationsModel.fromJson(m),
        _ => throw StateError('Unexpected createNotifications return type: ${result.runtimeType}')
      };

      _notifications.insert(0, model);
      notifyListeners();
      return model;
    } on DioError catch (e) {
      debugPrint('🔔 [createNotification] DioError: status=${e.response?.statusCode} data=${e.response?.data}');
      return null;
    } catch (e) {
      debugPrint('🔔 [createNotification] error: $e');
      return null;
    }
  }

  Future<int> fetchUnreadLocalNotificationsCount() async {
    try {
      final List<ActiveNotification> active =
      await _localNotificationsPlugin.getActiveNotifications();
      return active.length;
    } catch (e) {
      debugPrint('Error fetching local notifications: $e');
      return 0;
    }
  }

  Future<int> getCombinedUnreadCount(String userId) async {
    await fetchNotifications(userId);
    final local = await fetchUnreadLocalNotificationsCount();
    return unreadNotificationsCount + local;
  }


  // ADD: fetch a user by id
  Future<Map<String, dynamic>?> fetchUserById(String userId) async {
    try {
      final resp = await _dio.get('https://racheeta.pythonanywhere.com/users/$userId/');
      if (resp.statusCode == 200 && resp.data is Map<String, dynamic>) {
        return resp.data as Map<String, dynamic>;
      }
    } catch (e, st) {
      debugPrint('❌ [fetchUserById] $e\n$st');
    }
    return null;
  }

// ADD: fetch a medical center by the user's id (try both hyphen/underscore variants)
  Future<Map<String, dynamic>?> fetchCenterByUserId(String userId) async {
    Future<Map<String, dynamic>?> _try(String path) async {
      final resp = await _dio.get('https://racheeta.pythonanywhere.com/$path/',
        queryParameters: {'user': userId},
      );
      if (resp.statusCode == 200 && resp.data is List && (resp.data as List).isNotEmpty) {
        return ((resp.data as List).first) as Map<String, dynamic>;
      }
      return null;
    }

    try {
      return await _try('medical-center') ?? await _try('medical_center');
    } catch (e, st) {
      debugPrint('❌ [fetchCenterByUserId] $e\n$st');
      return null;
    }
  }
// ADD: fetch offers for a given service provider userId
  Future<List<Map<String, dynamic>>> fetchOffersByServiceProviderId(String spUserId) async {
    try {
      // main endpoint
      final r = await _dio.get(
        'https://racheeta.pythonanywhere.com/offers/',
        queryParameters: {
          'service_provider_id': spUserId,
          'is_archived': 'false',
        },
      );
      if (r.statusCode == 200 && r.data is List) {
        final list = (r.data as List)
            .whereType<Map<String, dynamic>>()
            .toList();

        // sort newest first if create_date exists
        list.sort((a, b) {
          final ad = DateTime.tryParse('${a['create_date'] ?? ''}') ?? DateTime(1970);
          final bd = DateTime.tryParse('${b['create_date'] ?? ''}') ?? DateTime(1970);
          return bd.compareTo(ad);
        });

        return list;
      }
    } catch (e, st) {
      debugPrint('❌ [fetchOffersByServiceProviderId] $e\n$st');
    }
    return <Map<String, dynamic>>[];
  }

}
