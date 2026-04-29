import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constansts/constants.dart';
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

/// ───────────────────────── "Medical Center" Dashboard ─────────────────────────
/// Handles both `medical_center` and the typo-ed `mdeidcal_center`.
class ResponsiveMDCenterDashboard extends StatefulWidget {
  const ResponsiveMDCenterDashboard({
    Key? key,
    required this.userId,      // UUID of User record
    required this.centerId,    // UUID of MedicalCenter record
    required this.centerName,  // Full name for greeting
    required this.userType,    // "medical_center" or "mdeidcal_center"
  }) : super(key: key);

  final String userId;
  final String centerId;
  final String centerName;
  final String userType;

  @override
  State<ResponsiveMDCenterDashboard> createState() => _MDCenterDashState();
}

class _MDCenterDashState extends State<ResponsiveMDCenterDashboard> {
  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();
  late final NotificationsRetroDisplayGetProvider _notiProv;
  Timer? _notiTimer;
  Timer? _reservationTimer;
  List<NoticationsModel> _notifications = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🧠 MDCenterDashboard → userId   = ${widget.userId}');
    debugPrint('🧠 MDCenterDashboard → centerId = ${widget.centerId}');
    debugPrint('🧠 MDCenterDashboard → centerName = ${widget.centerName}');
    debugPrint('🧠 MDCenterDashboard → userType = ${widget.userType}');

    // grab the injected provider
    _notiProv = context.read<NotificationsRetroDisplayGetProvider>();
    _initLocalNotifications();
    _refreshAll();

    // poll every 5m for noti, 3m for reservations
    _notiTimer      = Timer.periodic(const Duration(minutes: 5), (_) => _refreshNotifications(silent: true));
    _reservationTimer = Timer.periodic(const Duration(minutes: 3), (_) => _refreshReservations());
  }

  @override
  void dispose() {
    _notiTimer?.cancel();
    _reservationTimer?.cancel();
    super.dispose();
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _fln.initialize(settings);
  }

  Future<void> _refreshAll() async {
    setState(() => _loading = true);
    await Future.wait([
      _refreshNotifications(),
      _refreshReservations(),
    ]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _refreshNotifications({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      _notifications = await _notiProv.fetchNotifications(widget.centerId);
    } catch (e) {
      debugPrint('[MC-DASH] notification error → $e');
    }
    if (!silent && mounted) setState(() => _loading = false);
  }

  Future<void> _refreshReservations() async {
    try {
      final prov = context.read<ReservationRetroDisplayGetProvider>();
      final reservations = await prov.fetchAllReservationsForServiceProvider(widget.centerId, context);
      prov.mergeReservations(reservations);  // update internal list
      debugPrint('[MC-DASH] ✅ Reservations updated for center: ${reservations.length}');
    } catch (e) {
      debugPrint('[MC-DASH] reservation error → $e');
    }
  }


  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    context.read<TokenProvider>().updateToken('');
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => MedicaWelcomeScreen()),
            (_) => false,
      );
    }
  }

  Future<void> _sendTestNotification() async {
    await NotificationService.instance.showLocal(
      title: 'اختبار',
      body: 'هذا إشعار تجريبي من لوحة تحكم المركز الطبي',
      alsoCache: true,
    );
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => NotificationList(
        notifications: _notifications,
        onNotificationTap: _markAsRead,
      ),
    );
  }

  Future<void> _markAsRead(NoticationsModel n) async {
    try {
      n.isRead = true;
      await _notiProv.createNotification(
        user: n.user!,
        notificationText: n.notificationText!,
        isRead: true,
        createUser: n.createUser,
        updateUser: n.updateUser,
      );
      _refreshNotifications(silent: true);
    } catch (e) {
      debugPrint('[MC-DASH] mark-as-read error → $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationsRetroDisplayGetProvider>().unreadNotificationsCount;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text('لوحة تحكم المركز الطبي', style: kAppBarDashboardTextStyle),
        actions: [
          IconButton(
            icon: NotificationBadge(unreadCount: unread),
            onPressed: _showNotificationsSheet,
          ),
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => Navigator.pushNamed(context, '/messages'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
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
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text('مرحبا بك , ${widget.centerName}',
                          style: const TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 16),
                    // your custom MD stats
                    MDCentersStatistics(),
                    const SizedBox(height: 24),
                    // today's reservations
                    BaseTodayAppointments(
                      userType : widget.userType,
                      userId   : widget.userId,
                      hspId    : widget.centerId,
                      userName : widget.centerName,
                    ),
                    const SizedBox(height: 24),
                    // action buttons (reuse doctor widget)
                    ActionButtonsWidget(userType: widget.userType),
                  ],
                ),
              ),
            ),
            if (_loading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendTestNotification,
        child: const Icon(Icons.notifications_active),
      ),
    );
  }
}
