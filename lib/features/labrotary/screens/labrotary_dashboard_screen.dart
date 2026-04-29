
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../dashboard/base_today_appointments.dart';
import '../../../services/notification_service.dart';
import '../../../token_provider.dart';
import '../../common_screens/signup_login/screens/medical_welcome_screen.dart';
import '../../doctors/widgets/dashboard_widgets/action_buttons_widget.dart';
import '../../doctors/widgets/dashboard_widgets/stastics_widgets.dart';
import '../../doctors/widgets/dashboard_widgets/today_appointments_widget.dart';
import '../../doctors/widgets/notification_widgets/notification_badge_widget.dart';
import '../../doctors/widgets/notification_widgets/notifications_list.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../notifications/model/notification_model.dart';
import '../../reservations/providers/reservations_provider.dart';
import '../providers/labs_provider.dart';
import '../../../constansts/constants.dart';

import '../../../widgets/dashboard_widget/drawer_widget.dart';


/// A Doctor Dashboard that now accepts userId and userName
class ResponsiveLabrotaryDashboard extends StatefulWidget {
  /// The userType (e.g. "doctor")
  final String userType;

  /// The ID of the current user
  final String userId;

  /// The ID of the current doctor (same as userId or different as needed)
  final String labrotaryId;

  /// The name of the current user
  final String userName;

  const ResponsiveLabrotaryDashboard({
    Key? key,
    required this.userType,
    required this.userId,
    required this.userName,
    required this.labrotaryId,
  }) : super(key: key);

  @override
  _ResponsiveLabrotaryDashboardState createState() =>
      _ResponsiveLabrotaryDashboardState();
}

class _ResponsiveLabrotaryDashboardState extends State<ResponsiveLabrotaryDashboard> {
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Notifications polling timer (already in your code)
  Timer? _notificationPollingTimer;
  // <-- Add a reservations refresh timer
  Timer? _reservationRefreshTimer;

  List<NoticationsModel> notifications = [];
  bool _isLoading = false;
  bool _hasInitialLoaded = false;
  late String labrotaryId = '';

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadNotifications(silent: false); // show spinner on first call
    _startNotificationPolling();
    _loadLabId();
    // Start the reservations refresh timer (every 3 minutes)
    _startReservationRefresh();
  }

  @override
  void dispose() {
    _notificationPollingTimer?.cancel();
    _reservationRefreshTimer?.cancel();
    super.dispose();
  }

// after you finish reading nurseId:
  Future<void> _loadLabId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      labrotaryId = prefs.getString("labrotary_id") ?? widget.labrotaryId;
    });

    debugPrint("Loaded Labrotary ID: $labrotaryId");

    // 👇  NEW: pull reservations immediately
    _fetchReservations();
  }

  // -------------------------------------------
  // Notifications Code (Unchanged)
  // -------------------------------------------
  void _initializeNotifications() {
    const initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    _localNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    tokenProvider.updateToken("");
    debugPrint("User logged out.");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MedicaWelcomeScreen()),
    );
  }

  Future<void> _loadNotifications({bool silent = false}) async {
    if (!silent && !_hasInitialLoaded) {
      setState(() => _isLoading = true);
    }
    try {
      final provider = Provider.of<NotificationsRetroDisplayGetProvider>(
        context,
        listen: false,
      );
      final fetchedNotifications = await provider.fetchNotifications(labrotaryId);
      setState(() {
        notifications = fetchedNotifications;
      });
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      if (!silent && !_hasInitialLoaded) {
        setState(() {
          _isLoading = false;
          _hasInitialLoaded = true;
        });
      }
    }
  }

  void _startNotificationPolling() {
    _notificationPollingTimer =
        Timer.periodic(const Duration(minutes: 1), (timer) {
          _loadNotifications(silent: true);
        });
  }

  // -------------------------------------------
  // NEW: Reservations Auto-Refresh Timer
  // -------------------------------------------
  void _startReservationRefresh() {
    _reservationRefreshTimer =
        Timer.periodic(const Duration(minutes: 1), (timer) {
          _fetchReservations();
        });
  }

  Future<void> _fetchReservations() async {
    try {
      await Provider.of<ReservationRetroDisplayGetProvider>(context,
          listen: false)
          .fetchMyFullReservations(context);
      debugPrint("Reservations refreshed at ${DateTime.now()}");
    } catch (e) {
      debugPrint("Error fetching reservations: $e");
    }
  }

  void _markNotificationAsRead(NoticationsModel notification) async {
    final provider = Provider.of<NotificationsRetroDisplayGetProvider>(
      context,
      listen: false,
    );
    try {
      notification.isRead = true;
      await provider.createNotification(
        user: notification.user!,
        notificationText: notification.notificationText!,
        isRead: true,
        createUser: notification.createUser,
        updateUser: notification.updateUser,
      );
      _loadNotifications(silent: true);
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
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

  Future<void> _sendTestNotification() async {
    await NotificationService.instance.showLocal(
      title: 'اختبار',
      body: 'هذا إشعار تجريبي من لوحة التحكم',
      alsoCache: true,
    );
  }

  // -------------------------------------------
  // Build UI
  // -------------------------------------------
  @override
  Widget build(BuildContext context) {
    final notifProvider =
    Provider.of<NotificationsRetroDisplayGetProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          title: Text(
            '${widget.userType} لوحة تحكم ',
            style: kAppBarDashboardTextStyle,
          ),
          actions: [
            IconButton(
              icon: NotificationBadge(
                unreadCount: notifProvider.unreadNotificationsCount,
              ),
              onPressed: _showNotificationsDropdown,
            ),
            IconButton(
              icon: const Icon(Icons.chat, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/messages');
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _logout,
            ),
          ],
        ),
        drawer: DrawerWidget(
          userType: widget.userType,
          userId: widget.userId,
          hspId: widget.labrotaryId,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 90.0),
                    child: Text(
                      'مرحبا بك , ${widget.userName} ',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  Stastics(),
                  BaseTodayAppointments(
                    userType: widget.userType,
                    userId: widget.userId,
                    hspId: widget.labrotaryId,
                    userName: widget.userName,
                  ),
                  const SizedBox(height: 20),
                  ActionButtonsWidget(userType: widget.userType),
                ],
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _sendTestNotification,
          child: const Icon(Icons.send),
        ),
      ),
    );
  }
}

