import 'package:flutter/material.dart';

import 'menu_item_widget.dart';
import 'message_widget.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text('المساعدة', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        children: [
          MenuItem(
            icon: Icons.email,
            label: 'أرسل لنا',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SendMessagePage(),
              ),
            ),
          ),
          // MenuItem(
          //   icon: Icons.phone,
          //   label: 'اتصل بنا',
          //   onTap: () {
          //     // Action for calling support
          //   },
          // ),
        ],
      ),
    );
  }
}
