import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';

import '../../features/doctors/widgets/dashboard_widgets/stastics_widgets.dart';
import '../../features/doctors/widgets/notification_widgets/notification_badge_widget.dart';
import '../../features/doctors/widgets/notification_widgets/notifications_list.dart';
import '../../features/notifications/model/notification_model.dart';
import '../../features/notifications/providers/notifications_provider.dart';
import '../../widgets/dashboard_widget/drawer_widget.dart';

class ResponsiveHSPDashboard extends StatefulWidget {
  final String userType;
  final String userId;
  final String hspId;
  final String userName;

  const ResponsiveHSPDashboard({
    super.key,
    required this.userType,
    required this.userId,
    required this.hspId,
    required this.userName,
  });

  @override
  State<ResponsiveHSPDashboard> createState() => _ResponsiveHSPDashboardState();
}

class _ResponsiveHSPDashboardState extends State<ResponsiveHSPDashboard> {
  List<NoticationsModel> notifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<NotificationsRetroDisplayGetProvider>(context, listen: false);
      final fetchedNotifications = await provider.fetchNotifications(widget.hspId);
      if (mounted) {
        setState(() {
          notifications = fetchedNotifications;
        });
      }
    } catch (_) {
    } finally {
      if (!silent && mounted) setState(() => _isLoading = false);
    }
  }

  // Helper for silent updates
  bool get silent => true; 

  void _markNotificationAsRead(NoticationsModel notification) async {
    final provider = Provider.of<NotificationsRetroDisplayGetProvider>(context, listen: false);
    try {
      await provider.markAsRead(notification.id);
      _loadNotifications();
    } catch (_) {}
  }

  void _showNotificationsDropdown() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) {
        return NotificationList(
          notifications: notifications,
          onNotificationTap: _markNotificationAsRead,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = Provider.of<NotificationsRetroDisplayGetProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RacheetaColors.surface,
        appBar: AppBar(
          title: Text('${widget.userType} - لوحة التحكم'),
          actions: [
            IconButton(
              icon: NotificationBadge(unreadCount: notifProvider.unreadNotificationsCount),
              onPressed: _showNotificationsDropdown,
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () => Navigator.pushNamed(context, '/messages'),
            ),
          ],
        ),
        drawer: DrawerWidget(
          userType: widget.userType,
          userId: widget.userId,
          hspId: widget.hspId,
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: RacheetaColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'أهلاً بك،',
                          style: TextStyle(color: RacheetaColors.textSecondary, fontSize: 14),
                        ),
                        Text(
                          widget.userName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: RacheetaColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Stastics(),
                  const SizedBox(height: 16),
                  MockTodayAppointmentsWidget(userType: widget.userType, hspId: widget.hspId),
                ],
              ),
            ),
      ),
    );
  }
}

class MockTodayAppointmentsWidget extends StatelessWidget {
  final String userType;
  final String hspId;
  const MockTodayAppointmentsWidget({super.key, required this.userType, required this.hspId});

  @override
  Widget build(BuildContext context) {
    return const RacheetaSectionHeader(
      title: 'حجوزات اليوم',
      subtitle: 'لديك 5 حجوزات مؤكدة لهذا اليوم',
    );
  }
}
