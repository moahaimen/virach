// lib/features/doctors/screens/doctor_dashboard_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/notification_service.dart';
import '../../../token_provider.dart';
import '../../../widgets/dashboard_widget/drawer_widget.dart';
import '../../../widgets/home_screen_widgets/appBar_widget.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../notifications/screens/notification_list_page.dart';
import '../../registration/hsps/screen/hsp_login_screen.dart';
import '../../registration/patient/screen/patient_login.dart';
import '../../reservations/providers/reservations_provider.dart';
import '../models/doctor_request_model.dart';
import '../providers/doctors_provider.dart';
import '../widgets/dashboard_widgets/action_buttons_widget.dart';
import '../widgets/dashboard_widgets/stastics_widgets.dart';
import '../widgets/dashboard_widgets/today_appointments_widget.dart';
import 'doctor_request_screen.dart'; // full list screen

/// Doctor dashboard showing summary and preview of center join requests.
class ResponsiveDoctorDashboard extends StatefulWidget {
  final String userType;
  final String userId;
  final String doctorId;
  final String userName;

  const ResponsiveDoctorDashboard({
    super.key,
    required this.userType,
    required this.userId,
    required this.userName,
    required this.doctorId,
  });

  @override
  State<ResponsiveDoctorDashboard> createState() => _ResponsiveDoctorDashboardState();
}

class _ResponsiveDoctorDashboardState extends State<ResponsiveDoctorDashboard> {
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  Timer? _reservationTimer;
  Timer? _inviteTimer;
  bool _loading = false;
  late String _doctorId;
  bool _doctorProfileLoaded = false;

  // snackbar / request tracking
  Set<String> _knownRequestIds = {};
  bool _hasFlashedInitial = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[Dashboard] initState start');
    _initLocalNotifications();
    _bootstrap();
  }

  @override
  void dispose() {
    _reservationTimer?.cancel();
    _inviteTimer?.cancel();
    super.dispose();
  }

  void _initLocalNotifications() {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    _local.initialize(const InitializationSettings(android: android, iOS: ios));
    debugPrint('[Dashboard] Local notifications initialized');
  }

  Future<void> _bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _doctorId = prefs.getString('doctor_id') ?? widget.doctorId;
      debugPrint('[Dashboard] resolved doctorId=$_doctorId');

      await _fetchReservations();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final doctorProv = context.read<DoctorRetroDisplayGetProvider>();

        // load doctor profile (user endpoint first, fallback)
        try {
          await doctorProv.fetchDoctorViaUserEndpoint(widget.userId);
          if (doctorProv.currentDoctor != null) {
            _doctorProfileLoaded = true;
            debugPrint('[Dashboard] loaded currentDoctor via user endpoint: ${doctorProv.currentDoctor!.id}');
          } else {
            await doctorProv.loadDoctorById(widget.doctorId);
            if (doctorProv.currentDoctor != null) {
              _doctorProfileLoaded = true;
              debugPrint('[Dashboard] loaded currentDoctor via fallback id: ${doctorProv.currentDoctor!.id}');
            } else {
              debugPrint('[Dashboard] no currentDoctor after both attempts');
            }
          }
        } catch (e) {
          debugPrint('[Dashboard] error fetching doctor profile: $e');
        }

        // fetch join requests and maybe show snackbar
        try {
          await doctorProv.fetchMyDoctorRequests();
          final reqs = doctorProv.myDoctorRequests;
          debugPrint('[Dashboard] fetched myDoctorRequests count=${reqs.length}');
          _maybeShowSnackbar(reqs);
        } catch (e) {
          debugPrint('[Dashboard] error fetching doctor requests: $e');
        }

        // start periodic refreshes
        _startReservationRefresh();
        _startInviteRefresh();
      });
    } catch (e) {
      debugPrint('[Dashboard] bootstrap error: $e');
    }
  }

  void _startReservationRefresh() {
    debugPrint('[Dashboard] starting reservation timer');
    _reservationTimer = Timer.periodic(const Duration(minutes: 3), (_) => _fetchReservations());
  }

  Future<void> _fetchReservations() async {
    if (_doctorId.isEmpty) {
      debugPrint('[Dashboard] skip fetching reservations: doctorId empty');
      return;
    }
    try {
      debugPrint('[Dashboard] fetching reservations for $_doctorId');
      await context.read<ReservationRetroDisplayGetProvider>().fetchMyFullReservations(context);
      debugPrint('[Dashboard] reservations refreshed');
    } catch (e) {
      debugPrint('[Dashboard] reservation fetch error: $e');
    }
  }

  void _startInviteRefresh() {
    debugPrint('[Dashboard] starting invite refresh timer');
    _inviteTimer = Timer.periodic(const Duration(minutes: 3), (_) async {
      final prov = context.read<DoctorRetroDisplayGetProvider>();
      try {
        await prov.fetchMyDoctorRequests();
        debugPrint('[Dashboard] periodic requests count=${prov.myDoctorRequests.length}');
        _maybeShowSnackbar(prov.myDoctorRequests);
      } catch (e) {
        debugPrint('[Dashboard] periodic doctor requests error: $e');
      }
    });
  }

  void _maybeShowSnackbar(List<DoctorRequestModel> reqs) {
    if (reqs.isEmpty) return;
    final currentIds = reqs.map((r) => r.id).toSet();

    final hasNew = !_hasFlashedInitial
        ? currentIds.isNotEmpty
        : currentIds.difference(_knownRequestIds).isNotEmpty;

    if (hasNew) {
      _showSnackbarSequence();
      _hasFlashedInitial = true;
    }

    _knownRequestIds = currentIds;
  }

  void _showSnackbarSequence() {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    // flash 3 times
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 2500), () {
        if (!mounted) return;
        messenger.showSnackBar(_buildFlashSnackBar());
        debugPrint('[Dashboard] flash snackbar #${i + 1} shown');
      });
    }

    // persistent after flashes
    Future.delayed(const Duration(milliseconds: 3 * 2500 + 100), () {
      if (!mounted) return;
      messenger.showSnackBar(_buildPersistentSnackBar());
      debugPrint('[Dashboard] persistent snackbar shown');
    });
  }

  SnackBar _buildFlashSnackBar() {
    return SnackBar(
      content: GestureDetector(
        onTap: _goToRequestsPage,
        child: const Text(
          'هنالك طلب انضمام من مركز طبي',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        top: kToolbarHeight + MediaQuery.of(context).padding.top + 6,
        left: 16,
        right: 16,
      ),
      duration: const Duration(seconds: 2),
    );
  }

  SnackBar _buildPersistentSnackBar() {
    return SnackBar(
      content: GestureDetector(
        onTap: _goToRequestsPage,
        child: Row(
          children: const [
            Expanded(
              child: Text(
                'هنالك طلب انضمام من مركز طبي',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        top: kToolbarHeight + MediaQuery.of(context).padding.top + 6,
        left: 16,
        right: 16,
      ),
      duration: const Duration(days: 365),
      action: SnackBarAction(
        label: 'عرض',
        textColor: Colors.white,
        onPressed: _goToRequestsPage,
      ),
    );
  }

  void _goToRequestsPage() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorRequestsListPage(
          doctorId: widget.doctorId,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? '';
    await prefs.clear();
    context.read<TokenProvider>().updateToken('');

    final Widget target = ([
      'doctor',
      'nurse',
      'therapist',
      'pharmacist',
      'lab',
      'hospital',
      'medical_center',
      'beauty_center'
    ].contains(role))
        ? const HSPLoginPage()
        : LoginPatientScreen();

    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => target), (_) => false);
    }
  }

  Future<void> _onNotificationTap() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? widget.userId;
    debugPrint('[Dashboard] notification tap userId=$userId');
    try {
      await context.read<NotificationsRetroDisplayGetProvider>().fetchLatest15(userId);
    } catch (e) {
      debugPrint('[Dashboard] notifications fetch error: $e');
    }
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationListPage(userId: userId)));
    }
  }

  String _extractCenterName(DoctorRequestModel r) {
    final raw = r.toJson();
    if (raw['center'] is Map && raw['center']['center_name'] != null) {
      return raw['center']['center_name'].toString();
    } else if (raw['center_data'] is Map && raw['center_data']['name'] != null) {
      return raw['center_data']['name'].toString();
    } else if (raw['center_id'] != null) {
      return raw['center_id'].toString();
    } else if (raw['center'] is String) {
      return raw['center'];
    }
    return 'مركز غير معروف';
  }

  String _formatDate(DoctorRequestModel r) {
    final raw = r.toJson();
    final created = raw['create_date'] ?? raw['createDate'];
    if (created is String) return created.split('T').first;
    if (created is DateTime) return created.toString().split('T').first;
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    final doctorProv = context.watch<DoctorRetroDisplayGetProvider>();
    final reqs = doctorProv.myDoctorRequests;
    final doctor = doctorProv.currentDoctor;

    final latest = reqs.isNotEmpty ? reqs.first : null;

    return Scaffold(
      appBar: RacheetaAppBar(
        title: '${widget.userType} لوحة تحكم',
        showNotification: true,
        onNotificationTap: _onNotificationTap,
        showLogout: true,
        onLogout: _logout,
      ),
      drawer: DrawerWidget(
        userType: widget.userType,
        userId: widget.userId,
        hspId: widget.doctorId,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preview card for latest incoming request
                if (latest != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: InkWell(
                        onTap: _goToRequestsPage,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                          child: Row(
                            children: [
                              const Icon(Icons.local_hospital, size: 30),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _extractCenterName(latest),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'أُرسلت ${_formatDate(latest)}',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                // Greeting
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 4),
                  child: Text('مرحبا بك , ${widget.userName}', style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 4),
                 Stastics(),
                TodayAppointments(
                  userType: widget.userType,
                  userId: widget.userId,
                  doctorId: widget.doctorId,
                  userName: widget.userName,
                ),

                const SizedBox(height: 20),
                ActionButtonsWidget(userType: widget.userType),
                const SizedBox(height: 12),
              ],
            ),
          ),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => NotificationService.instance.showLocal(title: 'اختبار', body: 'هذا إشعار تجريبي', alsoCache: true),
        child: const Icon(Icons.send),
      ),
    );
  }
}
