import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/screens/home_screen.dart';
import '../features/common_screens/signup_login/screens/welcome_page.dart';
import '../features/splash_screen/splash_screen.dart';
import '../features/doctors/screens/doctors_dashboard_screen.dart';
import '../features/nurse/screens/nurse_dashboard_screen.dart';
import '../features/pharmacist/screens/pharmacy_dashboard_screen.dart';
import '../features/therapist/screens/therapist_dashboard_screen.dart';
import '../features/labrotary/screens/labrotary_dashboard_screen.dart';
import '../features/hospitals/screens/hospital_dashboard_screen.dart';
import '../features/beauty_centers/screens/beauty_dashboard_screen.dart';
import '../features/medical_centre/screens/medical_centre_dashboard_screen.dart';
import '../features/jobseeker/screens/job_seeker_side/final/browse_jobs.dart';

Future<Widget> getDashboard() async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('Login_access_token') ?? '';
  final isRegistered = (prefs.getBool('isRegistered') ?? false) &&
      accessToken.isNotEmpty &&
      prefs.getString('user_id') != null;
  final role = prefs.getString('role') ?? 'patient';
  final userId = prefs.getString('user_id') ?? '';
  final userName = prefs.getString('full_name') ?? 'User';

  if (!isRegistered) return  WelcomeScreen();

  switch (role.toLowerCase()) {
    case 'doctor':
      return ResponsiveDoctorDashboard(userType: role, userId: userId, userName: userName, doctorId: '');
    case 'nurse':
      return ResponsiveNurseDashboard(userType: role, userId: userId, userName: userName, nurseId: '');
    case 'pharmacist':
      return ResponsivePharmacyDashboard(userType: role, userId: userId, userName: userName, pharmaId: '');
    case 'therapist':
      return ResponsiveTherapistDashboard(userType: role, userId: userId, userName: userName, therapistId: '');
    case 'lab':
    case 'laboratory':
      return ResponsiveLabrotaryDashboard(userType: role, userId: userId, userName: userName, labrotaryId: '');
    case 'hospital':
      return ResponsiveHospitalDashboard(userType: role, userId: userId, userName: userName, hospitalId: '');
    case 'beauty_center':
      return ResponsiveBeautyDashboard(userType: 'beauty_center', userId: userId, beautyId: '', userName: userName);
    case 'medical_center':
      return ResponsiveMDCenterDashboard(userType: role, centerId: userId, centerName: userName, userId: userId);
    case 'patient':
      return  HomeScreen();
    default:
      return  BrowseJobOffersScreen();
  }
}
