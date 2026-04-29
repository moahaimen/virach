import 'package:flutter/material.dart';

import '../../../constansts/constants.dart';

class ConversationsPage extends StatelessWidget {
  final List<Map<String, dynamic>> conversations = [
    {'name': 'Patient 1', 'message': 'Hello, Doctor!', 'time': '10:00 AM'},
    {'name': 'Patient 2', 'message': 'Can we reschedule?', 'time': '11:30 AM'},
    {
      'name': 'Patient 3',
      'message': 'Thank you for your advice!',
      'time': '1:45 PM'
    },
    // Add more conversations here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
      ),
      body: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: kConversationCircleAvatar,
                title: Text(conversations[index]['name']),
                subtitle: Text(conversations[index]['message']),
                trailing: Text(conversations[index]['time']),
                onTap: () {
                  // Navigate to conversation detail screen if needed
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
