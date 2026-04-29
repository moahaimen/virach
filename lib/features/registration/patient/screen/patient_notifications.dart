import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sample notifications data
    final List<String> notifications = [
      "Your appointment with Dr. Smith is confirmed for tomorrow.",
      "New message from Dr. Brown.",
      "Your prescription is ready for pickup.",
      "Reminder: You have an appointment next week.",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Color(0xFF007BFF),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.notifications, color: Colors.blue),
            title: Text(notifications[index]),
            onTap: () {
              // Handle notification tap, e.g., navigate to related page
            },
          );
        },
      ),
    );
  }
}
