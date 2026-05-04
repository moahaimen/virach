import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';

import '../providers/notifications_provider.dart';
import '../model/notification_model.dart';
import 'notification_detail_screen.dart';

class NotificationListPage extends StatefulWidget {
  final String userId;
  const NotificationListPage({super.key, required this.userId});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage>
    with TickerProviderStateMixin {
  bool _loading = true;
  List<NoticationsModel> _notes = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final prov = context.read<NotificationsRetroDisplayGetProvider>();
    try {
      final notes = await prov.fetchLatest15(widget.userId);
      if (mounted) {
        setState(() {
          _notes = notes;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    final prov = context.read<NotificationsRetroDisplayGetProvider>();
    final notes = await prov.fetchLatest15(widget.userId);
    if (mounted) {
      setState(() {
        _notes = notes;
      });
    }
  }

  List<NoticationsModel> filtered(NotificationType type) {
    return _notes.where((n) => n.type == type).toList();
  }

  IconData _iconForType(NotificationType t) {
    switch (t) {
      case NotificationType.offer:
        return Icons.local_offer_outlined;
      case NotificationType.request:
        return Icons.person_add_outlined;
      case NotificationType.reservation:
        return Icons.event_available_outlined;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  Color _colorForType(NotificationType t) {
    switch (t) {
      case NotificationType.offer:
        return Colors.purple;
      case NotificationType.request:
        return RacheetaColors.warning;
      case NotificationType.reservation:
        return RacheetaColors.primary;
      default:
        return RacheetaColors.textSecondary;
    }
  }

  Widget buildList(List<NoticationsModel> list) {
    if (list.isEmpty) {
      return const RacheetaEmptyState(
        icon: Icons.notifications_off_outlined,
        title: "لا توجد إشعارات",
        subtitle: "عند وصول تنبيهات جديدة ستظهر هنا.",
      );
    }
    final prov = context.read<NotificationsRetroDisplayGetProvider>();
    
    return RefreshIndicator(
      onRefresh: _refresh,
      color: RacheetaColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: list.length,
        itemBuilder: (_, i) {
          final n = list[i];
          final color = _colorForType(n.type);
          final icon = _iconForType(n.type);

          return RacheetaCard(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(16),
            onTap: () {
              if (!n.isRead) prov.markAsRead(n.id);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotificationDetailScreen(notification: n)),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    if (!n.isRead)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: RacheetaColors.danger,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.notificationText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: n.isRead ? FontWeight.normal : FontWeight.w800,
                          color: RacheetaColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('dd-MM-yyyy • hh:mm a').format(n.createDate),
                        style: const TextStyle(fontSize: 11, color: RacheetaColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
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
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RacheetaColors.surface,
        appBar: AppBar(
          title: const Text('الإشعارات'),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: RacheetaColors.primary,
            labelColor: RacheetaColors.primary,
            labelStyle: const TextStyle(fontWeight: FontWeight.w900),
            unselectedLabelColor: RacheetaColors.textSecondary,
            tabs: const [
              Tab(text: 'العروض'),
              Tab(text: 'الطلبات'),
              Tab(text: 'الحجوزات'),
              Tab(text: 'أخرى'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: RacheetaColors.primary))
            : TabBarView(
                controller: _tabController,
                children: [
                  buildList(filtered(NotificationType.offer)),
                  buildList(filtered(NotificationType.request)),
                  buildList(filtered(NotificationType.reservation)),
                  buildList(filtered(NotificationType.other)),
                ],
              ),
      ),
    );
  }
}
