import 'package:flutter/material.dart';

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
                _buildNotificationList(),
                _buildNotificationList(type: "chat"),
                _buildNotificationList(type: "reservation"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList({String? type}) {
    final filteredNotifications = notifications
        .where((notification) => type == null || notification == type)
        .toList();

    return ListView.builder(
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return ListTile(
          title: Text(notification.notificationText ?? "No content"),
          subtitle: Text(notification.createDate ?? "No date available"),
        );
      },
    );
  }
}
