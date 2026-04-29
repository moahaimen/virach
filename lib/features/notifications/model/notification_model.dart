// lib/features/notifications/model/notification_model.dart

enum NotificationType { offer, request, reservation, other }

NotificationType _inferTypeFromText(String text) {
  final t = text.toLowerCase();
  if (t.contains('عرض') || t.contains('offer')) return NotificationType.offer;
  if (t.contains('طلب') || t.contains('request')) return NotificationType.request;
  if (t.contains('حجز') || t.contains('reservation') || t.contains('appointment')) {
    return NotificationType.reservation;
  }
  return NotificationType.other;
}

class NoticationsModel {
  final String id;
  final String user;
  final String notificationText;
  final bool isRead;
  final DateTime createDate;
  final DateTime updateDate;
  final String? createUser;
  final String? updateUser;
  final bool isArchived;

  /// NEW: derived type for UI filtering & icons
  final NotificationType type;

  NoticationsModel({
    required this.id,
    required this.user,
    required this.notificationText,
    required this.isRead,
    required this.createDate,
    required this.updateDate,
    this.createUser,
    this.updateUser,
    required this.isArchived,
    required this.type,
  });

  factory NoticationsModel.fromJson(Map<String, dynamic> json) {
    final text = (json['notification_text'] as String?) ?? '';
    return NoticationsModel(
      id: json['id'] as String,
      user: json['user'] as String,
      notificationText: text,
      isRead: json['is_read'] as bool? ?? false,
      createDate: DateTime.parse(json['create_date'] as String),
      updateDate: DateTime.parse(json['update_date'] as String),
      createUser: json['create_user'] as String?,
      updateUser: json['update_user'] as String?,
      isArchived: json['is_archived'] as bool? ?? false,
      type: _inferTypeFromText(text),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user,
    'notification_text': notificationText,
    'is_read': isRead,
    'create_date': createDate.toIso8601String(),
    'update_date': updateDate.toIso8601String(),
    'create_user': createUser,
    'update_user': updateUser,
    'is_archived': isArchived,
    // type is derived client-side; no need to send to backend
  };

  NoticationsModel copyWith({
    String? id,
    String? user,
    String? notificationText,
    bool? isRead,
    DateTime? createDate,
    DateTime? updateDate,
    String? createUser,
    String? updateUser,
    bool? isArchived,
    NotificationType? type,
  }) {
    return NoticationsModel(
      id: id ?? this.id,
      user: user ?? this.user,
      notificationText: notificationText ?? this.notificationText,
      isRead: isRead ?? this.isRead,
      createDate: createDate ?? this.createDate,
      updateDate: updateDate ?? this.updateDate,
      createUser: createUser ?? this.createUser,
      updateUser: updateUser ?? this.updateUser,
      isArchived: isArchived ?? this.isArchived,
      type: type ?? this.type,
    );
  }

  NoticationsModel markRead() => copyWith(isRead: true);
  NoticationsModel markUnread() => copyWith(isRead: false);
}
