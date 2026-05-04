import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../notifications/model/notification_model.dart';

class NotificationTabs extends StatelessWidget {
  final List<NoticationsModel> notifications;

  const NotificationTabs({Key? key, required this.notifications})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: "All"),
              Tab(text: "Chats"),
              Tab(text: "Reservations"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildNotificationList(context),
                _buildNotificationList(context, type: "chat"),
                _buildNotificationList(context, type: "reservation"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(BuildContext context, {String? type}) {
    final filteredNotifications = notifications.toList();

    return ListView.builder(
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return ListTile(
          title: Text(notification.notificationText),
          subtitle: Text(DateFormat('yyyy-MM-dd').format(notification.createDate)),
        );
      },
    );
  }
}
