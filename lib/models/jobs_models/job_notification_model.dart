class JobNotification {
  final int notificationId;
  final int jobId;
  final int jobSeekerId;
  final String notificationText;
  final DateTime createdAt;

  JobNotification({
    required this.notificationId,
    required this.jobId,
    required this.jobSeekerId,
    required this.notificationText,
    required this.createdAt,
  });
}
