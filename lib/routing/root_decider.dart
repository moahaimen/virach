import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:racheeta/theme/app_theme.dart';
import '../di/dependency_ingection.dart';
import '../features/beauty_centers/screens/beauty_dashboard_screen.dart';
import '../features/common_screens/signup_login/screens/welcome_page.dart';
import '../features/doctors/screens/doctors_dashboard_screen.dart';
import '../features/hospitals/screens/hospital_dashboard_screen.dart';
import '../features/labrotary/screens/labrotary_dashboard_screen.dart';
import '../features/medical_centre/screens/medical_centre_dashboard_screen.dart';
import '../features/nurse/screens/nurse_dashboard_screen.dart';
import '../features/pharmacist/screens/pharmacy_dashboard_screen.dart';
import '../features/screens/home_screen.dart';
import '../features/splash_screen/splash_screen.dart';
import '../features/therapist/screens/therapist_dashboard_screen.dart';

class RootDecider extends StatefulWidget {
  const RootDecider({super.key});

  @override
  State<RootDecider> createState() => _RootDeciderState();
}

class _RootDeciderState extends State<RootDecider> {
  bool _isLoading = true;
  String? _role;
  String? _userId;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ensure DI is ready with current token
    await setup();

    final token = prefs.getString('access_token') ?? prefs.getString('Login_access_token');
    final userId = prefs.getString('user_id');
    final role = prefs.getString('role');
    final name = prefs.getString('full_name');

    if (mounted) {
      setState(() {
        _userId = userId;
        _role = role;
        _userName = name;
        _isLoading = false;
      });
    }

    if (token == null || userId == null || isTokenExpired(token)) {
      if (mounted) {
        setState(() {
          _userId = null;
          _role = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SplashScreen();

    if (_userId == null || _role == null) {
      return const WelcomeScreen();
    }

    final userId = _userId!;
    final userName = _userName ?? 'مستخدم';
    final roleLower = _role!.toLowerCase();
    final prefs = locator<SharedPreferences>();

    switch (roleLower) {
      case 'doctor':
        return ResponsiveDoctorDashboard(
          userType: _role!,
          userId: userId,
          userName: userName,
          doctorId: prefs.getString('doctor_id') ?? '',
        );
      case 'nurse':
        return ResponsiveNurseDashboard(
          userType: _role!,
          userId: userId,
          userName: userName,
          nurseId: prefs.getString('nurse_id') ?? '',
        );
      case 'pharmacist':
        return ResponsivePharmacyDashboard(
          userType: _role!,
          userId: userId,
          userName: userName,
          pharmaId: prefs.getString('pharma_id') ?? '',
        );
      case 'therapist':
      case 'physical-therapist':
        return ResponsiveTherapistDashboard(
          userType: _role!,
          userId: userId,
          userName: userName,
          therapistId: prefs.getString('therapist_id') ?? '',
        );
      case 'lab':
      case 'laboratory':
      case 'labrotary':
        return ResponsiveLabrotaryDashboard(
          userType: _role!,
          userId: userId,
          userName: userName,
          labrotaryId: prefs.getString('labrotary_id') ?? '',
        );
      case 'hospital':
        return ResponsiveHospitalDashboard(
          userType: _role!,
          userId: userId,
          userName: userName,
          hospitalId: prefs.getString('hospital_id') ?? '',
        );
      case 'beauty_center':
        return ResponsiveBeautyDashboard(
          userType: _role!,
          userId: userId,
          userName: userName,
          beautyId: prefs.getString('beautycenter_id') ?? '',
        );
      case 'medical_center':
      case 'medical_centre':
      case 'mdeidcal_center':
        return ResponsiveMDCenterDashboard(
          userType: _role!,
          userId: userId,
          centerId: prefs.getString('medical_center_id') ?? userId,
          centerName: userName,
        );
      case 'patient':
      default:
        return const HomeScreen();
    }
  }
}
