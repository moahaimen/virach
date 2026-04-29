import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../chatting/providers/chatting_provider.dart';
import '../models/doctors_model.dart';
import '../../chatting/models/chatting_model.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId; // current user (patient) id
  final DoctorModel doctor; // DoctorModel is expected

  ChatScreen(
      {required this.currentUserId, required this.doctor, required patient});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<ChattingModel> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    setState(() => _isLoading = true);

    try {
      final doctorId =
          widget.doctor.id ?? 'unknown'; // Get doctor id from the doctor model
      final provider =
          Provider.of<ChattingRetroDisplayGetProvider>(context, listen: false);

      final messages = await provider.fetchMessages(
        currentUserId: widget.currentUserId,
        doctorId: doctorId, // Use doctor.id, not the whole doctor model
      );

      setState(() => _messages = messages);
    } catch (e) {
      print("Error fetching messages: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();

    if (messageText.isEmpty) return;

    try {
      final doctorId = widget.doctor.id ?? 'unknown'; // Get the doctor id
      final provider =
          Provider.of<ChattingRetroDisplayGetProvider>(context, listen: false);

      final newMessage = await provider.sendMessage(
        currentUserId: widget.currentUserId,
        doctorId: doctorId, // Send doctorId, not the whole doctor
        messageText: messageText,
      );

      if (newMessage != null) {
        setState(() {
          _messages.add(newMessage);
          _messageController.clear();
        });
      }
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.doctor.user?.fullName ?? 'Doctor'}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return ListTile(
                        title: Text(message.messageText ?? ''),
                      );
                    },
                  ),
          ),
          TextField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: 'Type a message...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
