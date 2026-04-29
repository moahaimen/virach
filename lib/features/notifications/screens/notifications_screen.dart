// lib/features/notifications/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/notifications_provider.dart';
import '../model/notification_model.dart';
import 'notification_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  final String userId;
  const NotificationsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
  List<NoticationsModel> _notes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prov = context.read<NotificationsRetroDisplayGetProvider>();
    final notes = await prov.fetchLatest15(widget.userId);
    setState(() {
      _notes = notes;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
          ? const Center(child: Text('لا توجد إشعارات'))
          : ListView.separated(
        itemCount: _notes.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final n = _notes[i];
          return ListTile(
            leading: Icon(
              n.isRead == true ? Icons.mark_email_read : Icons.mark_email_unread,
              color: n.isRead == true ? Colors.grey : Colors.blue,
            ),
            title: Text(n.notificationText ?? '(بدون نص)'),
            subtitle: Text(
              DateFormat('dd-MM-yyyy • hh:mm a').format(n.createDate),
            ),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationDetailScreen(notification: n),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
