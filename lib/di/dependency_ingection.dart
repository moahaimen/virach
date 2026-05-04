import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/applicants/providers/applicants_provider.dart';
import '../features/beauty_centers/providers/beauty_centers_provider.dart';
import '../features/chatting/providers/chatting_provider.dart';
import '../features/doctors/providers/doctors_provider.dart';
import '../features/hospitals/providers/hospital_display_provider.dart';
import '../features/jobposting/provider/jobposting_provider.dart';
import '../features/jobseeker/providers/jobseeker_provider.dart';
import '../features/labrotary/providers/labs_provider.dart';
import '../features/medical_centre/providers/medical_centers_providers.dart';
import '../features/notifications/providers/notifications_provider.dart';
import '../features/nurse/providers/nurse_provider.dart';
import '../features/offers/providers/offers_provider.dart';
import '../features/pharmacist/providers/pharma_provider.dart';
import '../features/registration/patient/provider/patient_registration_provider.dart';
import '../features/reservations/providers/reservations_provider.dart';
import '../features/therapist/providers/therapist_provider.dart';

final GetIt locator = GetIt.instance;

/// ✅ Checks if a JWT token is expired.
bool isTokenExpired(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return true; // Invalid token

    final payload = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
    final exp = payload["exp"]; // Expiration timestamp

    return DateTime.now().millisecondsSinceEpoch > (exp * 1000);
  } catch (e) {
    return true; // Treat as expired if decoding fails
  }
}

/// ✅ Clears the stored JWT token to force re-login.
Future<void> clearStoredToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("access_token");
  await prefs.remove("Login_access_token");
  await prefs.remove("refresh_token");
}

/// ✅ Ensures providers are registered only once.
Future<void> setup() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Unify token storage: prefer 'access_token', fallback to 'Login_access_token'
  String jwtToken = prefs.getString("access_token") ?? prefs.getString("Login_access_token") ?? '';

  // Check token expiration
  if (jwtToken.isNotEmpty && isTokenExpired(jwtToken)) {
    await clearStoredToken();
    jwtToken = '';
  }
  
  if (!locator.isRegistered<SharedPreferences>()) {
    locator.registerLazySingleton<SharedPreferences>(() => prefs);
  }

  // ✅ Register providers with current token (or empty string)
  _registerProvider<DoctorRetroDisplayGetProvider>(() => DoctorRetroDisplayGetProvider(jwtToken));
  _registerProvider<ApplicantsProvider>(() => ApplicantsProvider(jwtToken));
  _registerProvider<JobSeekerRetroDisplayGetProvider>(() => JobSeekerRetroDisplayGetProvider(jwtToken));
  _registerProvider<PharmaRetroDisplayGetProvider>(() => PharmaRetroDisplayGetProvider(jwtToken));
  _registerProvider<PatientRetroDisplayGetProvider>(() => PatientRetroDisplayGetProvider(jwtToken));
  _registerProvider<HospitalRetroDisplayGetProvider>(() => HospitalRetroDisplayGetProvider(jwtToken));
  _registerProvider<MedicalCentersRetroDisplayGetProvider>(() => MedicalCentersRetroDisplayGetProvider(jwtToken));
  _registerProvider<LabsRetroDisplayGetProvider>(() => LabsRetroDisplayGetProvider(jwtToken));
  _registerProvider<BeautyCentersRetroDisplayGetProvider>(() => BeautyCentersRetroDisplayGetProvider(jwtToken));
  _registerProvider<OffersRetroDisplayGetProvider>(() => OffersRetroDisplayGetProvider(jwtToken));
  _registerProvider<TherapistRetroDisplayGetProvider>(() => TherapistRetroDisplayGetProvider(jwtToken));
  _registerProvider<ChattingRetroDisplayGetProvider>(() => ChattingRetroDisplayGetProvider(jwtToken));
  _registerProvider<NotificationsRetroDisplayGetProvider>(() => NotificationsRetroDisplayGetProvider(jwtToken));
  _registerProvider<NurseRetroDisplayGetProvider>(() => NurseRetroDisplayGetProvider(jwtToken));
  _registerProvider<JobPostingRetroDisplayGetProvider>(() => JobPostingRetroDisplayGetProvider(jwtToken));
  _registerProvider<ReservationRetroDisplayGetProvider>(() => ReservationRetroDisplayGetProvider(jwtToken));
}

/// **Helper function to safely register a provider**
void _registerProvider<T extends Object>(T Function() provider) {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
  locator.registerLazySingleton(provider);
}
