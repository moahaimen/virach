import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../di/dependency_ingection.dart';
import '../features/beauty_centers/providers/beauty_centers_provider.dart';
import '../features/beauty_centers/screens/beauty_dashboard_screen.dart';
import '../features/common_screens/signup_login/screens/welcome_page.dart';
import '../features/doctors/providers/doctors_provider.dart';
import '../features/doctors/screens/doctors_dashboard_screen.dart';
import '../features/hospitals/providers/hospital_display_provider.dart';
import '../features/hospitals/screens/hospital_dashboard_screen.dart';
import '../features/jobseeker/screens/job_seeker_side/final/browse_jobs.dart';
import '../features/labrotary/providers/labs_provider.dart';
import '../features/labrotary/screens/labrotary_dashboard_screen.dart';
import '../features/medical_centre/providers/medical_centers_providers.dart';
import '../features/medical_centre/screens/medical_centre_dashboard_screen.dart';
import '../features/nurse/providers/nurse_provider.dart';
import '../features/nurse/screens/nurse_dashboard_screen.dart';
import '../features/pharmacist/providers/pharma_provider.dart';
import '../features/pharmacist/screens/pharmacy_dashboard_screen.dart';
import '../features/screens/home_screen.dart';
import '../features/splash_screen/splash_screen.dart';
import '../features/therapist/providers/therapist_provider.dart';
import '../features/therapist/screens/therapist_dashboard_screen.dart';
import '../main.dart';
import 'dashboard_router.dart';

class RootDecider extends StatefulWidget {
  const RootDecider({super.key});

  @override
  State<RootDecider> createState() => _RootDeciderState();
}

class _RootDeciderState extends State<RootDecider> {
  bool _isLoading = true;
  bool _isRegistered = false;
  String _role = 'patient';
  String? _accessToken;
  String? _userId;
  String? _userName;
  String? _doctorId;
  String? _medicalCenterId;

  @override
  void initState() {
    super.initState();
    _checkRegistration();
  }

  Future<void> _checkRegistration() async {
    final prefs = await SharedPreferences.getInstance();

    // ⏳ Wait for up to 1s to ensure prefs are ready
    for (int i = 0; i < 10; i++) {
      final role = prefs.getString('role');
      final userId = prefs.getString('user_id');
      if (role != null && userId != null) break;
      debugPrint("⏳ [ROOT DECIDER] Waiting for prefs...");
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final accessToken       = prefs.getString('Login_access_token');
    final userId            = prefs.getString('user_id');
    final fullName          = prefs.getString('full_name');
    final storedRole        = prefs.getString('role');
    final doctorId          = prefs.getString('doctor_id');
    final medicalCenterId   = prefs.getString('medical_center_id');

    final isRegistered = (prefs.getBool('isRegistered') ?? false) &&
        (accessToken?.isNotEmpty ?? false) &&
        (userId?.isNotEmpty ?? false);

    // 🧠 Debug logs
    debugPrint("📦 [ROOT DECIDER] role            = $storedRole");
    debugPrint("📦 [ROOT DECIDER] user_id         = $userId");
    debugPrint("📦 [ROOT DECIDER] full_name       = $fullName");
    debugPrint("📦 [ROOT DECIDER] doctor_id       = $doctorId");
    debugPrint("📦 [ROOT DECIDER] medical_center_id = $medicalCenterId");

    setState(() {
      _accessToken      = accessToken;
      _userId           = userId;
      _userName         = fullName;
      _role             = storedRole ?? '';
      _doctorId         = doctorId ?? '';
      _medicalCenterId  = medicalCenterId ?? '';
      _isRegistered     = isRegistered;
      _isLoading        = false;
    });

    // 🔐 Apply token to all relevant providers
    final token = accessToken ?? '';
    if (token.isNotEmpty) {
      locator<DoctorRetroDisplayGetProvider>().updateToken(token);
      locator<NurseRetroDisplayGetProvider>().updateToken(token);
      locator<HospitalRetroDisplayGetProvider>().updateToken(token);
      locator<PharmaRetroDisplayGetProvider>().updateToken(token);
      locator<TherapistRetroDisplayGetProvider>().updateToken(token);
      locator<LabsRetroDisplayGetProvider>().updateToken(token);
      locator<BeautyCentersRetroDisplayGetProvider>().updateToken(token);
      locator<MedicalCentersRetroDisplayGetProvider>().updateToken(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }

    if (!_isRegistered || (_accessToken?.isEmpty ?? true) || _userId == null) {
      return  WelcomeScreen();
    }
    final userId = _userId!;
    final userName = _userName ?? 'User';

    switch (_role.toLowerCase()) {
      case 'doctor':

        return ResponsiveDoctorDashboard(
          userType: _role,
          userId: userId,
          userName: userName,
          doctorId: _doctorId ?? '',
        );
      case 'nurse':
        return ResponsiveNurseDashboard(
          userType: _role,
          userId: userId,
          userName: userName,
          nurseId: '',
        );
      case 'pharmacist':
        return ResponsivePharmacyDashboard(
          userType: _role,
          userId: userId,
          userName: userName,
          pharmaId: '',
        );
      case 'therapist':
        return ResponsiveTherapistDashboard(
          userType: _role,
          userId: userId,
          userName: userName,
          therapistId: '',
        );
      case 'lab':
      case 'laboratory':
        return ResponsiveLabrotaryDashboard(
          userType: _role,
          userId: userId,
          userName: userName,
          labrotaryId: '',
        );
      case 'hospital':
        return ResponsiveHospitalDashboard(
          userType: _role,
          userId: userId,
          userName: userName,
          hospitalId: '',
        );
      case 'beauty_center':
        return ResponsiveBeautyDashboard(
          userType: 'beauty_center',
          userId: userId,
          beautyId: '',
          userName: userName,
        );
      case 'medical_center':
      case 'medical_center':
      case 'mdeidcal_center': {
        final centerId = (_medicalCenterId?.isNotEmpty ?? false)
            ? _medicalCenterId!
            : userId;            // fallback

        debugPrint('➡️  To Dash: userId=$userId  centerId=$centerId');

        return ResponsiveMDCenterDashboard(
          userType   : _role,
          userId     : userId,
          centerId   : centerId,
          centerName : userName,
        );
      }

      case 'patient':
        return  HomeScreen();
      default:
        return  BrowseJobOffersScreen();
    }
  }
}
// Saved jobseeker_id: