import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final int unreadCount;

  const NotificationBadge({Key? key, required this.unreadCount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Icon(Icons.notifications, size: 30, color: Colors.white),
        if (unreadCount > 0)
          Positioned(
            right: 0,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }
}
