import 'package:flutter/material.dart';

class MarkAllAsReadButton extends StatelessWidget {
  final VoidCallback onMarkAllAsRead;

  const MarkAllAsReadButton({Key? key, required this.onMarkAllAsRead})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onMarkAllAsRead,
      child: Text('Mark All as Read'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
