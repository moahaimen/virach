import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Notification 1'),
            subtitle: const Text('Sender: System, Time: 9:00 AM'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NotificationDetailPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Notification 2'),
            subtitle: const Text('Sender: Admin, Time: 10:00 AM'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NotificationDetailPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class NotificationDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sender: System'),
            SizedBox(height: 10),
            Text('Time: 9:00 AM'),
            SizedBox(height: 10),
            Text('Details: This is the detail of the notification.'),
          ],
        ),
      ),
    );
  }
}
