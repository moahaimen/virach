import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';

import '../../../dashboard/base_today_appointments.dart';
import '../../../services/notification_service.dart';
import '../../../token_provider.dart';
import '../../common_screens/signup_login/screens/medical_welcome_screen.dart';
import '../../doctors/widgets/dashboard_widgets/action_buttons_widget.dart';
import '../../doctors/widgets/notification_widgets/notification_badge_widget.dart';
import '../../doctors/widgets/notification_widgets/notifications_list.dart';
import '../../notifications/model/notification_model.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../reservations/providers/reservations_provider.dart';
import '../../../widgets/dashboard_widget/drawer_widget.dart';
import '../widgets/medical_centre_stastics_widget.dart';

class ResponsiveMDCenterDashboard extends StatefulWidget {
  const ResponsiveMDCenterDashboard({
    super.key,
    required this.userId,
    required this.centerId,
    required this.centerName,
    required this.userType,
  });

  final String userId;
  final String centerId;
  final String centerName;
  final String userType;

  @override
  State<ResponsiveMDCenterDashboard> createState() => _MDCenterDashState();
}

class _MDCenterDashState extends State<ResponsiveMDCenterDashboard> {
  Timer? _notiTimer;
  Timer? _reservationTimer;
  List<NoticationsModel> _notifications = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refreshAll();
    _notiTimer = Timer.periodic(const Duration(minutes: 5), (_) => _refreshNotifications(silent: true));
    _reservationTimer = Timer.periodic(const Duration(minutes: 3), (_) => _refreshReservations());
  }

  @override
  void dispose() {
    _notiTimer?.cancel();
    _reservationTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    setState(() => _loading = true);
    try {
      await Future.wait([
        _refreshNotifications(silent: true),
        _refreshReservations(),
      ]);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _refreshNotifications({bool silent = false}) async {
    try {
      final prov = context.read<NotificationsRetroDisplayGetProvider>();
      final notes = await prov.fetchNotifications(widget.centerId);
      if (mounted) setState(() => _notifications = notes);
    } catch (_) {}
  }

  Future<void> _refreshReservations() async {
    try {
      final prov = context.read<ReservationRetroDisplayGetProvider>();
      final reservations = await prov.fetchAllReservationsForServiceProvider(widget.centerId, context);
      prov.mergeReservations(reservations);
    } catch (_) {}
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    context.read<TokenProvider>().updateToken('');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MedicaWelcomeScreen()),
      (_) => false,
    );
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => NotificationList(
        notifications: _notifications,
        onNotificationTap: (n) async {
          await context.read<NotificationsRetroDisplayGetProvider>().markAsRead(n.id);
          _refreshNotifications(silent: true);
        },
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
          title: const Text('لوحة تحكم المركز الطبي'),
          actions: [
            IconButton(
              icon: NotificationBadge(unreadCount: unread),
              onPressed: _showNotificationsSheet,
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
          hspId: widget.centerId,
        ),
        body: RefreshIndicator(
          onRefresh: _refreshAll,
          color: RacheetaColors.primary,
          child: _loading 
            ? const Center(child: CircularProgressIndicator(color: RacheetaColors.primary))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                          Text(widget.centerName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: RacheetaColors.textPrimary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    MDCentersStatistics(),
                    const SizedBox(height: 16),
                    BaseTodayAppointments(
                      userType: widget.userType,
                      userId: widget.userId,
                      hspId: widget.centerId,
                      userName: widget.centerName,
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
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => NotificationService.instance.showLocal(title: 'اختبار', body: 'إشعار تجريبي من المركز الطبي', alsoCache: true),
          child: const Icon(Icons.send),
        ),
      ),
    );
  }
}
