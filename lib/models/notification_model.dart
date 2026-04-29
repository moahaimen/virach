class NotificationModel {
  final int notificationId;
  final int userId;
  final String notificationText;
  final DateTime createdAt;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.notificationText,
    required this.createdAt,
  });
}
