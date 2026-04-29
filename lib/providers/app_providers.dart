// lib/providers/app_providers.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:racheeta/providers/theme_provider.dart';        // ← ThemeProvider lives here
import 'package:racheeta/providers/specialty_provider.dart';
import '../auth_provider.dart';
import '../di/dependency_ingection.dart';
import '../features/applicants/providers/applicants_provider.dart';
import '../features/beauty_centers/providers/beauty_centers_provider.dart';
import '../features/chatting/providers/chatting_provider.dart';
import '../features/common_screens/signup_login/providers/login_provider.dart';
import '../features/doctors/providers/doctors_provider.dart';
import '../features/hospitals/providers/hospital_display_provider.dart';
import '../features/jobposting/provider/jobposting_provider.dart';
import '../features/jobseeker/providers/jobseeker_provider.dart';
import '../features/labrotary/providers/labs_provider.dart';
import '../features/medical_centre/providers/medical_centers_providers.dart';
import '../features/notifications/providers/notifications_provider.dart';
import '../features/nurse/providers/nurse_provider.dart';
import '../features/offers/providers/offers_provider.dart';
import '../features/offers/services/coupon_services.dart';
import '../features/pharmacist/providers/pharma_provider.dart';
import '../features/registration/patient/provider/patient_registration_provider.dart';
import '../features/reservations/providers/reservations_provider.dart';
import '../features/therapist/providers/therapist_provider.dart';
import '../services/connectivity_check_service.dart';
import '../token_provider.dart';
import 'header_option_provider.dart';

/// Wraps [child] in a MultiProvider that registers every ChangeNotifier.
///
/// This function hides all of the individual `ChangeNotifierProvider(...)`
/// calls, so that callers need only say:
///   buildAppProviders(prefs: prefs, child: AppEntry())
/// and they get everything registered (ThemeProvider, TokenProvider, etc.).
Widget buildAppProviders({
  required SharedPreferences prefs,
  required Widget child,
}) {
  return MultiProvider(
    providers: [
      Provider<ConnectivityService>(create: (_) => ConnectivityService()),  // ✅

      ChangeNotifierProvider( create: (_) => TokenProvider()..loadTokenFromPreferences(),),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),  // ← ThemeProvider is here
      ChangeNotifierProvider(create: (_) => locator<LoginProvider>()),
      ChangeNotifierProvider(create: (_) => locator<ApplicantsProvider>()),
      // ChangeNotifierProvider(create: (_) => locator<DoctorRetroDisplayGetProvider>()),
// 2) Then for each HSP provider (example for Doctor):
      ChangeNotifierProxyProvider<TokenProvider, DoctorRetroDisplayGetProvider>(
        create: (_) => DoctorRetroDisplayGetProvider(''),       // start with empty
        update: (_, tokenProv, previous) {
          final token = tokenProv.accessToken ?? '';
          if (previous != null) {
            previous.setAuthToken(token);                        // inject new token
            return previous;
          }
          return DoctorRetroDisplayGetProvider(token);           // first-time init
        },
      ),
      ChangeNotifierProvider(create: (_) => locator<PatientRetroDisplayGetProvider>()),
      ChangeNotifierProvider(create: (_) => locator<NurseRetroDisplayGetProvider>()),
      ChangeNotifierProvider(create: (_) => locator<BeautyCentersRetroDisplayGetProvider>()),
      ChangeNotifierProvider(create: (_) => locator<JobSeekerRetroDisplayGetProvider>()),
      ChangeNotifierProvider(create: (_) => locator<LabsRetroDisplayGetProvider>()),
      ChangeNotifierProvider(create: (_) => locator<TherapistRetroDisplayGetProvider>()),
      ChangeNotifierProvider(create: (_) => locator<MedicalCentersRetroDisplayGetProvider>()),
      ChangeNotifierProvider(create: (_) => locator<HospitalRetroDisplayGetProvider>()),
  ChangeNotifierProxyProvider<TokenProvider, OffersRetroDisplayGetProvider>(
          create: (_) => OffersRetroDisplayGetProvider(''),
         update: (_, tokenProv, previous) {
           previous ??= OffersRetroDisplayGetProvider('');
           previous.setAuthToken(tokenProv.accessToken ?? '');
           return previous;
         },
  ),      ChangeNotifierProvider(create: (_) => HeaderOptionProvider()),
      ChangeNotifierProvider(create: (_) => SpecialtyProvider()),

  ChangeNotifierProxyProvider<TokenProvider, ReservationRetroDisplayGetProvider>(
     create: (_) => ReservationRetroDisplayGetProvider(''),
     update: (_, tokenProv, previous) {
  previous ??= ReservationRetroDisplayGetProvider('');
       previous.setAuthToken(tokenProv.accessToken ?? '');
       return previous;
     },
   ),

      ChangeNotifierProvider(create: (_) => locator<PharmaRetroDisplayGetProvider>()),
      ChangeNotifierProvider(create: (_) => locator<JobPostingRetroDisplayGetProvider>()),
      ChangeNotifierProvider(create: (_) => locator<ChattingRetroDisplayGetProvider>()),
// 👉  INSERT **ONE** LINE FOR COUPONS  -----------------------------
      ChangeNotifierProvider<CouponService>(
        create: (_) => CouponService()..init(), // init() loads saved coupons
      ),
      // -----------------------------------------------------------------

      // Notifications provider needs the token from prefs:
      //  ⬇︎ one Notifications provider for the whole app
      ChangeNotifierProxyProvider<TokenProvider, NotificationsRetroDisplayGetProvider>(
        create: (_) => NotificationsRetroDisplayGetProvider(''), // empty token first
        update: (_, tokenProv, notifProv) {
          notifProv ??= NotificationsRetroDisplayGetProvider('');
          notifProv.setAuthToken(tokenProv.accessToken ?? ''); // keep token in sync
          return notifProv;
        },
      ),

      ChangeNotifierProvider(create: (_) => locator<AuthProvider>()),
    ],
    child: child,
  );
}
