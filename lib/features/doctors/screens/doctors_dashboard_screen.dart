import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:racheeta/theme/app_theme.dart';
import 'package:racheeta/widgets/racheeta_ui/racheeta_ui.dart';

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
import 'doctor_request_screen.dart';

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
  Timer? _reservationTimer;
  Timer? _inviteTimer;
  bool _isLoading = false;
  late String _doctorId;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _reservationTimer?.cancel();
    _inviteTimer?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _doctorId = prefs.getString('doctor_id') ?? widget.doctorId;

      _fetchReservations();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final doctorProv = context.read<DoctorRetroDisplayGetProvider>();
        try {
          await doctorProv.fetchDoctorViaUserEndpoint(widget.userId);
          await doctorProv.fetchMyDoctorRequests();
        } catch (_) {}

        _startReservationRefresh();
        _startInviteRefresh();
      });
    } catch (_) {}
  }

  void _startReservationRefresh() {
    _reservationTimer = Timer.periodic(const Duration(minutes: 3), (_) => _fetchReservations());
  }

  Future<void> _fetchReservations() async {
    if (_doctorId.isEmpty) return;
    try {
      await context.read<ReservationRetroDisplayGetProvider>().fetchMyFullReservations(context);
    } catch (_) {}
  }

  void _startInviteRefresh() {
    _inviteTimer = Timer.periodic(const Duration(minutes: 3), (_) async {
      try {
        await context.read<DoctorRetroDisplayGetProvider>().fetchMyDoctorRequests();
      } catch (_) {}
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? '';
    await prefs.clear();
    if (!mounted) return;
    context.read<TokenProvider>().updateToken('');

    final Widget target = ([
      'doctor', 'nurse', 'therapist', 'pharmacist', 'lab', 'hospital', 'medical_center', 'beauty_center'
    ].contains(role))
        ? const HSPLoginPage()
        : LoginPatientScreen();

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => target), (_) => false);
  }

  Future<void> _onNotificationTap() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? widget.userId;
    Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationListPage(userId: userId)));
  }

  String _extractCenterName(DoctorRequestModel r) {
    final raw = r.toJson();
    if (raw['center'] is Map) return raw['center']['center_name']?.toString() ?? 'مركز طبي';
    if (raw['center_data'] is Map) return raw['center_data']['name']?.toString() ?? 'مركز طبي';
    return 'طلب انضمام جديد';
  }

  @override
  Widget build(BuildContext context) {
    final doctorProv = context.watch<DoctorRetroDisplayGetProvider>();
    final reqs = doctorProv.myDoctorRequests;
    final latest = reqs.isNotEmpty ? reqs.first : null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: RacheetaColors.surface,
        appBar: RacheetaAppBar(
          title: 'لوحة تحكم الطبيب',
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
                        const Text('أهلاً بك دكتور،', style: TextStyle(color: RacheetaColors.textSecondary, fontSize: 14)),
                        Text(widget.userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: RacheetaColors.textPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  if (latest != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: RacheetaCard(
                        padding: const EdgeInsets.all(16),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorRequestsListPage(doctorId: widget.doctorId))),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: RacheetaColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.business_center_outlined, color: RacheetaColors.danger, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('طلب انضمام جديد', style: TextStyle(color: RacheetaColors.danger, fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text(_extractCenterName(latest), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: RacheetaColors.textPrimary)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_back_ios_new, size: 16, color: RacheetaColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  const Stastics(),
                  const SizedBox(height: 16),
                  TodayAppointments(
                    userType: widget.userType,
                    userId: widget.userId,
                    doctorId: widget.doctorId,
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
      ),
    );
  }
}
