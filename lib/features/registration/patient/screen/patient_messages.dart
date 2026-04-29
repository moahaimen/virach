import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sample messages data
    final List<Map<String, String>> conversations = [
      {"name": "Dr. Smith", "lastMessage": "I'll see you at 10 AM tomorrow."},
      {
        "name": "Dr. Brown",
        "lastMessage": "Please remember to bring your test results."
      },
      {"name": "Dr. Green", "lastMessage": "Your lab results are ready."},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        backgroundColor: Color(0xFF007BFF),
      ),
      body: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(conversations[index]["name"]!),
            subtitle: Text(conversations[index]["lastMessage"]!),
            onTap: () {
              // Handle conversation tap, navigate to detailed message thread
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessageThreadPage(
                    doctorName: conversations[index]["name"]!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MessageThreadPage extends StatelessWidget {
  final String doctorName;

  MessageThreadPage({required this.doctorName});

  @override
  Widget build(BuildContext context) {
    // Sample messages in the thread
    final List<String> messages = [
      "Doctor: How are you feeling today?",
      "You: I'm feeling better, thank you!",
      "Doctor: Great! Remember to take your medication.",
      "You: Will do, thanks!",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Conversation with $doctorName'),
        backgroundColor: Color(0xFF007BFF),
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          bool isDoctor = messages[index].startsWith("Doctor");
          return ListTile(
            title: Align(
              alignment:
                  isDoctor ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color:
                      isDoctor ? Colors.blue.shade100 : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(messages[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
