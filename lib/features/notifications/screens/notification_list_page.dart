// lib/features/notifications/screens/notification_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/notifications_provider.dart';
import '../model/notification_model.dart';
import 'notification_detail_screen.dart';

class NotificationListPage extends StatefulWidget {
  final String userId;
  const NotificationListPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage>
    with TickerProviderStateMixin {
  bool _loading = true;
  List<NoticationsModel> _notes = [];
  late TabController _tabController;

  // track unread count to show “new notifications” banner
  int _lastUnreadCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final prov = context.read<NotificationsRetroDisplayGetProvider>();
    final notes = await prov.fetchLatest15(widget.userId);
    setState(() {
      _notes = notes;
      _loading = false;
      _lastUnreadCount = notes.where((n) => !n.isRead).length;
    });
  }

  // Refresh & show banner if unread increased
  Future<void> _refresh() async {
    final prov = context.read<NotificationsRetroDisplayGetProvider>();
    final notes = await prov.fetchLatest15(widget.userId);
    final currentUnread = notes.where((n) => !n.isRead).length;

    if (currentUnread > _lastUnreadCount && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: const Text(
            'لديك إشعارات جديدة',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          backgroundColor: Colors.blueAccent,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            left: 12,
            right: 12,
            top: (kToolbarHeight + MediaQuery.of(context).padding.top) + 10,
            bottom: 0,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    setState(() {
      _notes = notes;
      _lastUnreadCount = currentUnread;
    });
  }

  List<NoticationsModel> filtered(NotificationType type) {
    return _notes.where((n) => n.type == type).toList();
  }

  IconData _iconForType(NotificationType t) {
    switch (t) {
      case NotificationType.offer:
        return Icons.local_offer;
      case NotificationType.request:
        return Icons.person_add_alt;
      case NotificationType.reservation:
        return Icons.event;
      case NotificationType.other:
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(NotificationType t) {
    switch (t) {
      case NotificationType.offer:
        return Colors.purple;
      case NotificationType.request:
        return Colors.orange;
      case NotificationType.reservation:
        return Colors.teal;
      case NotificationType.other:
      default:
        return Colors.blueGrey;
    }
  }

  Widget buildList(List<NoticationsModel> list) {
    if (list.isEmpty) {
      return const Center(child: Text('لا توجد إشعارات'));
    }
    final prov = context.read<NotificationsRetroDisplayGetProvider>();
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        itemCount: list.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final n = list[i];
          final leadingIcon = _iconForType(n.type);
          final leadingColor = _colorForType(n.type);

          return Dismissible(
            key: ValueKey(n.id),
            direction: DismissDirection.startToEnd, // swipe RIGHT to mark read
            background: Container(
              color: Colors.green.withOpacity(0.15),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Row(
                children: [
                  Icon(Icons.done_all, color: Colors.green),
                  SizedBox(width: 8),
                  Text('تعليم كمقروء', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
            onDismissed: (_) async {
              await prov.markAsRead(n.id);
              setState(() {
                _notes = _notes.map((x) => x.id == n.id ? x.markRead() : x).toList();
              });
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: leadingColor.withOpacity(0.15),
                child: Icon(leadingIcon, color: leadingColor),
              ),
              title: Text(
                n.notificationText,
                style: TextStyle(
                  fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600,
                ),
              ),
              subtitle: Text(DateFormat('dd-MM-yyyy • hh:mm a').format(n.createDate)),
              trailing: n.isRead
                  ? IconButton(
                icon: const Icon(Icons.mark_email_unread),
                tooltip: 'عدم التعليم كمقروء',
                onPressed: () async {
                  await prov.markAsUnread(n.id);
                  setState(() {
                    _notes = _notes.map((x) => x.id == n.id ? x.markUnread() : x).toList();
                  });
                },
              )
                  : IconButton(
                icon: const Icon(Icons.mark_email_read),
                tooltip: 'تعليم كمقروء',
                onPressed: () async {
                  await prov.markAsRead(n.id);
                  setState(() {
                    _notes = _notes.map((x) => x.id == n.id ? x.markRead() : x).toList();
                  });
                },
              ),
              onLongPress: () async {
                // quick toggle on long press
                if (n.isRead) {
                  await prov.markAsUnread(n.id);
                  setState(() {
                    _notes = _notes.map((x) => x.id == n.id ? x.markUnread() : x).toList();
                  });
                } else {
                  await prov.markAsRead(n.id);
                  setState(() {
                    _notes = _notes.map((x) => x.id == n.id ? x.markRead() : x).toList();
                  });
                }
              },
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NotificationDetailScreen(notification: n)),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'العروض'),
            Tab(text: 'الطلبات'),
            Tab(text: 'الحجوزات'),
            Tab(text: 'أخرى'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          buildList(filtered(NotificationType.offer)),
          buildList(filtered(NotificationType.request)),
          buildList(filtered(NotificationType.reservation)),
          buildList(filtered(NotificationType.other)),
        ],
      ),
    );
  }
}
