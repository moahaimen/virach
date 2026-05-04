import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';

import '../../../dashboard/base_today_appointments.dart';
import '../../../services/notification_service.dart';
import '../../../token_provider.dart';
import '../../common_screens/signup_login/screens/medical_welcome_screen.dart';
import '../../doctors/widgets/dashboard_widgets/action_buttons_widget.dart';
import '../../doctors/widgets/dashboard_widgets/stastics_widgets.dart';
import '../../doctors/widgets/notification_widgets/notification_badge_widget.dart';
import '../../doctors/widgets/notification_widgets/notifications_list.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../notifications/model/notification_model.dart';
import '../../reservations/providers/reservations_provider.dart';
import '../../../widgets/dashboard_widget/drawer_widget.dart';

class ResponsivePharmacyDashboard extends StatefulWidget {
  final String userType;
  final String userId;
  final String pharmaId;
  final String userName;

  const ResponsivePharmacyDashboard({
    super.key,
    required this.userType,
    required this.userId,
    required this.userName,
    required this.pharmaId,
  });

  @override
  State<ResponsivePharmacyDashboard> createState() => _ResponsivePharmacyDashboardState();
}

class _ResponsivePharmacyDashboardState extends State<ResponsivePharmacyDashboard> {
  Timer? _notificationPollingTimer;
  Timer? _reservationRefreshTimer;

  List<NoticationsModel> notifications = [];
  bool _isLoading = false;
  late String _pharmaId;

  @override
  void initState() {
    super.initState();
    _pharmaId = widget.pharmaId;
    _bootstrap();
  }

  @override
  void dispose() {
    _notificationPollingTimer?.cancel();
    _reservationRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    _pharmaId = prefs.getString("pharma_id") ?? widget.pharmaId;
    
    _fetchReservations();
    _loadNotifications();
    
    _notificationPollingTimer = Timer.periodic(const Duration(minutes: 3), (_) => _loadNotifications(silent: true));
    _reservationRefreshTimer = Timer.periodic(const Duration(minutes: 3), (_) => _fetchReservations());
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    context.read<TokenProvider>().updateToken("");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MedicaWelcomeScreen()),
    );
  }

  Future<void> _loadNotifications({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final provider = Provider.of<NotificationsRetroDisplayGetProvider>(context, listen: false);
      final fetched = await provider.fetchNotifications(_pharmaId);
      if (mounted) setState(() => notifications = fetched);
    } catch (_) {
    } finally {
      if (!silent && mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchReservations() async {
    try {
      await Provider.of<ReservationRetroDisplayGetProvider>(context, listen: false).fetchMyFullReservations(context);
    } catch (_) {}
  }

  void _markNotificationAsRead(NoticationsModel notification) async {
    final provider = Provider.of<NotificationsRetroDisplayGetProvider>(context, listen: false);
    try {
      await provider.markAsRead(notification.id);
      _loadNotifications(silent: true);
    } catch (_) {}
  }

  void _showNotificationsDropdown() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => NotificationList(
        notifications: notifications,
        onNotificationTap: _markNotificationAsRead,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationsRetroDisplayGetProvider>().unreadNotificationsCount;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RacheetaColors.surface,
        appBar: AppBar(
          title: const Text('لوحة تحكم الصيدلية'),
          actions: [
            IconButton(
              icon: NotificationBadge(unreadCount: unread),
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
          hspId: _pharmaId,
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
                        const Text('أهلاً بك،', style: TextStyle(color: RacheetaColors.textSecondary, fontSize: 14)),
                        Text(widget.userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: RacheetaColors.textPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Stastics(),
                  const SizedBox(height: 16),
                  BaseTodayAppointments(
                    userType: widget.userType,
                    userId: widget.userId,
                    hspId: _pharmaId,
                    userName: widget.userName,
                  ),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text('إجراءات سريعة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: RacheetaColors.textPrimary)),
                  ),
                  ActionButtonsWidget(userType: widget.userType),
                ],
              ),
            ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => NotificationService.instance.showLocal(title: 'اختبار', body: 'هذا إشعار تجريبي', alsoCache: true),
          child: const Icon(Icons.send),
        ),
      ),
    );
  }
}
