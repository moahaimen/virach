
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';

import '../providers/notifications_provider.dart';
import '../model/notification_model.dart';
import 'notification_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  final String userId;
  const NotificationsScreen({super.key, required this.userId});

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
    try {
      final prov = context.read<NotificationsRetroDisplayGetProvider>();
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RacheetaColors.surface,
        appBar: AppBar(title: const Text('الإشعارات')),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: RacheetaColors.primary))
            : _notes.isEmpty
                ? const RacheetaEmptyState(
                    icon: Icons.notifications_off_outlined,
                    title: "لا توجد إشعارات",
                    subtitle: "تنبيهاتك الجديدة ستظهر هنا فور وصولها.",
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _notes.length,
                    itemBuilder: (_, i) {
                      final n = _notes[i];
                      return RacheetaCard(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        padding: const EdgeInsets.all(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => NotificationDetailScreen(notification: n)),
                          );
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: n.isRead ? RacheetaColors.border.withOpacity(0.3) : RacheetaColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                n.isRead ? Icons.notifications_none : Icons.notifications_active,
                                color: n.isRead ? RacheetaColors.textSecondary : RacheetaColors.primary,
                                size: 22,
                              ),
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
      ),
    );
  }
}
