import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../notifications/model/notification_model.dart';

class NotificationList extends StatelessWidget {
  final List<NoticationsModel> notifications;
  final Function(NoticationsModel) onNotificationTap;

  const NotificationList(
      {Key? key, required this.notifications, required this.onNotificationTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return ListTile(
          leading: Icon(
            notification.isRead
                ? Icons.notifications
                : Icons.notifications_active,
            color: notification.isRead ? Colors.grey : Colors.blue,
          ),
          title: Text(notification.notificationText),
          subtitle: Text(DateFormat('yyyy-MM-dd').format(notification.createDate)),
          onTap: () => onNotificationTap(notification),
        );
      },
    );
  }
}
