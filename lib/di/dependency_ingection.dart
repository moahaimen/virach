import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../features/applicants/providers/applicants_provider.dart';
import '../features/beauty_centers/providers/beauty_centers_provider.dart';
import '../features/chatting/providers/chatting_provider.dart';
import '../features/common_screens/signup_login/models/login_model.dart';
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
import '../core/services/api_client.dart';

final GetIt locator = GetIt.instance;

/// ✅ Checks if a JWT token is expired.
bool isTokenExpired(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return true; // Invalid token

    final payload = json.decode(utf8.decode(base64Url.decode(parts[1])));
    final exp = payload["exp"]; // Expiration timestamp

    return DateTime.now().millisecondsSinceEpoch > (exp * 1000);
  } catch (e) {
    print("⚠️ Error decoding token: $e");
    return true; // Treat as expired if decoding fails
  }
}

/// ✅ Clears the stored JWT token to force re-login.
Future<void> clearStoredToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("Login_access_token");
  print("🚨 Token deleted. The app will now log in with mo@mo.com");
}

/// ✅ Ensures providers are registered only once.
Future<void> setup() async {
  final prefs = await SharedPreferences.getInstance();
  String jwtToken = prefs.getString("Login_access_token") ?? '';
  print("🔑 [Setup] Checking stored token: $jwtToken");

  // Check token expiration
  if (jwtToken.isNotEmpty && isTokenExpired(jwtToken)) {
    print("⚠️ [Setup] Token expired. Clearing stored token...");
    await prefs.remove("Login_access_token");
    jwtToken = '';
  }
  locator.registerLazySingleton<SharedPreferences>(() => prefs);

  // If no token, perform automatic login
  if (jwtToken.isEmpty) {
    print("🚨 [Setup] No valid token found. Attempting automatic login...");
    try {
      final Dio dioForLogin = Dio(BaseOptions(contentType: "application/json"));
      final ApiClient loginApiClient = ApiClient(dioForLogin);
      final LoginResponse loginResponse = await loginApiClient.login({
        "email": "mo@mo.com",
        "password": "1",
      });

      if (loginResponse.access != null) {
        jwtToken = loginResponse.access!;
        print("✅ [Setup] Login successful. New Token: $jwtToken");
        await prefs.setString("Login_access_token", jwtToken);
      } else {
        print("❌ [Setup] Login failed. No token received.");
      }
    } catch (e) {
      print("❌ [Setup] Error during login: ${e.toString()}");
      jwtToken = '';
    }
  }

  if (jwtToken.isEmpty) {
    print("🛑 [Setup] Warning: No valid token available. Providers may fail.");
  }

  print("📌 [Setup] Final Token Before Provider Initialization: $jwtToken");

  // **💡 Unregister existing providers before registering them again**
  if (locator.isRegistered<DoctorRetroDisplayGetProvider>()) {
    locator.unregister<DoctorRetroDisplayGetProvider>();
    print("♻️ [Setup] DoctorRetroDisplayGetProvider unregistered.");
  }

  locator.registerLazySingleton(() => DoctorRetroDisplayGetProvider(jwtToken));
  print("✅ [Setup] DoctorRetroDisplayGetProvider registered successfully.");

  // ✅ Unregister & Register other providers safely
  _registerProvider<ApplicantsProvider>(() => ApplicantsProvider(jwtToken));
  // _registerProvider<ApplicantsProvider>(() => ThemeProvider());
  _registerProvider<JobSeekerRetroDisplayGetProvider>(
      () => JobSeekerRetroDisplayGetProvider(jwtToken));

  _registerProvider<PharmaRetroDisplayGetProvider>(
      () => PharmaRetroDisplayGetProvider(jwtToken));
  _registerProvider<PatientRetroDisplayGetProvider>(
      () => PatientRetroDisplayGetProvider(jwtToken));

  _registerProvider<HospitalRetroDisplayGetProvider>(
      () => HospitalRetroDisplayGetProvider(jwtToken));
  _registerProvider<MedicalCentersRetroDisplayGetProvider>(
      () => MedicalCentersRetroDisplayGetProvider(jwtToken));
  _registerProvider<LabsRetroDisplayGetProvider>(
      () => LabsRetroDisplayGetProvider(jwtToken));
  _registerProvider<BeautyCentersRetroDisplayGetProvider>(
      () => BeautyCentersRetroDisplayGetProvider(jwtToken));
  _registerProvider<OffersRetroDisplayGetProvider>(
      () => OffersRetroDisplayGetProvider(jwtToken));
  _registerProvider<TherapistRetroDisplayGetProvider>(
      () => TherapistRetroDisplayGetProvider(jwtToken));
  _registerProvider<ChattingRetroDisplayGetProvider>(
      () => ChattingRetroDisplayGetProvider(jwtToken));
  _registerProvider<NotificationsRetroDisplayGetProvider>(
      () => NotificationsRetroDisplayGetProvider(jwtToken));
  _registerProvider<NurseRetroDisplayGetProvider>(
      () => NurseRetroDisplayGetProvider(jwtToken));
  _registerProvider<JobPostingRetroDisplayGetProvider>(
      () => JobPostingRetroDisplayGetProvider(jwtToken));
  _registerProvider<ReservationRetroDisplayGetProvider>(
      () => ReservationRetroDisplayGetProvider(jwtToken));

  print("✅ [Setup] All Providers Successfully Registered.");
}

/// **Helper function to safely register a provider**
void _registerProvider<T extends Object>(T Function() provider) {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
    print("♻️ [Setup] Unregistered provider: $T");
  }
  locator.registerLazySingleton(provider);
  print("✅ [Setup] Registered provider: $T");
}


