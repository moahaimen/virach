import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SendMessagePage extends StatefulWidget {
  @override
  _SendMessagePageState createState() => _SendMessagePageState();
}

class _SendMessagePageState extends State<SendMessagePage> {
  final TextEditingController _messageController = TextEditingController();

  Future<void> _openWhatsAppChat() async {
    String message = _messageController.text.trim();
    String phoneNumber = "9647721837469"; // Example phone number (Iraq)

    if (message.isNotEmpty) {
      final String whatsappUrl =
          "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";

      if (await canLaunch(whatsappUrl)) {
        await launch(whatsappUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("WhatsApp is not installed")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء كتابة رسالة قبل الإرسال")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text('ارسل ملاحظاتك للادارة',
            style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 200,
              ),
              const Text(' اضفط هنا للذهاب  الى واتساب لكتابة رسالتك '),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _openWhatsAppChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                ),
                child: const Text(
                  'ارسل لنا',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
