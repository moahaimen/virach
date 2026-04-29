// lib/dashboard/screens/responsive_hsp_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constansts/constants.dart';
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
    Key? key,
    required this.userType,
    required this.userId,
    required this.hspId,
    required this.userName,
  }) : super(key: key);

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
      setState(() {
        notifications = fetchedNotifications;
      });
    } catch (e) {
      debugPrint("Error fetching notifications: \$e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _markNotificationAsRead(NoticationsModel notification) async {
    final provider = Provider.of<NotificationsRetroDisplayGetProvider>(context, listen: false);
    try {
      notification.isRead = true;
      await provider.createNotification(
        user: notification.user!,
        notificationText: notification.notificationText!,
        isRead: true,
        createUser: notification.createUser,
        updateUser: notification.updateUser,
      );
      _loadNotifications();
    } catch (e) {
      debugPrint("Error marking notification as read: \$e");
    }
  }

  void _showNotificationsDropdown() {
    showModalBottomSheet(
      context: context,
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text('${widget.userType} لوحة تحكم ', style: kAppBarDashboardTextStyle),
        actions: [
          IconButton(
            icon: NotificationBadge(unreadCount: notifProvider.unreadNotificationsCount),
            onPressed: _showNotificationsDropdown,
          ),
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/messages'),
          ),
        ],
      ),
      drawer: DrawerWidget(
        userType: widget.userType,
        userId: widget.userId,
        hspId: widget.hspId,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 90.0),
                  child: Text('مرحبا بك , ${widget.userName}',
                      style: const TextStyle(fontSize: 16, color: Colors.black)),
                ),
                // Using mock implementations instead of abstract widgets directly
                MockStatisticsWidget(userType: widget.userType, hspId: widget.hspId),
                MockTodayAppointmentsWidget(userType: widget.userType, hspId: widget.hspId),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

// Temporary placeholders to fix abstract class instantiation
class MockStatisticsWidget extends StatelessWidget {
  final String userType;
  final String hspId;

  const MockStatisticsWidget({required this.userType, required this.hspId});

  @override
  Widget build(BuildContext context) {
    return const Text('🔧 Statistics Placeholder');
  }
}

class MockTodayAppointmentsWidget extends StatelessWidget {
  final String userType;
  final String hspId;

  const MockTodayAppointmentsWidget({required this.userType, required this.hspId});

  @override
  Widget build(BuildContext context) {
    return const Text('📅 Appointments Placeholder');
  }
}
