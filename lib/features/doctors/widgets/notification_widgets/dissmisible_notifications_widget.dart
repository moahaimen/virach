import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../notifications/model/notification_model.dart';

class DismissibleNotification extends StatelessWidget {
  final NoticationsModel notification;
  final Function(String) onDelete;

  const DismissibleNotification(
      {Key? key, required this.notification, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDelete(notification.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        color: Colors.red,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        title: Text(notification.notificationText),
        subtitle: Text(DateFormat('yyyy-MM-dd').format(notification.createDate)),
      ),
    );
  }
}
