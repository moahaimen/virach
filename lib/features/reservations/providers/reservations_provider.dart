import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../token_provider.dart';
import '../../reservations/models/reservation_model.dart';
import '../services/api_client.dart'; // Make sure this is your correct path

class ReservationRetroDisplayGetProvider with ChangeNotifier {
  // ------------------------------------------------
  // FIELDS
  // ------------------------------------------------
  late ApiClient _apiClient;
  late final Dio _dio;
  /// The local storage of partial reservations (from /me/)
  List<ReservationModel> _reservations = [];
  List<ReservationModel> get reservations => _reservations;

  /// The local storage of full reservations (IDs from /me/ + fetchOneReservationById)
  List<ReservationModel> _fullReservations = [];
  List<ReservationModel> get fullReservations => _fullReservations;

  Map<String, dynamic>? _meData;
  Map<String, dynamic>? get meData => _meData;

  // ------------------------------------------------
  // CONSTRUCTOR
  // ------------------------------------------------
  ReservationRetroDisplayGetProvider(String token) {
    // This is the initial Dio client for the _apiClient usage
    _dio = Dio()..options.headers['Authorization'] = 'JWT $token';
    _apiClient = ApiClient(_dio);
  }
  void updateToken(String newToken) {
    _dio.options.headers['Authorization'] = 'JWT $newToken';
    notifyListeners();
  }
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'JWT $token';
  }

  // ------------------------------------------------
  // CREATE RESERVATION
  // ------------------------------------------------
  Future<ReservationModel?> createReservation({
    required String patientId,
    required String patientEmail,
    required String patientFullName,
    required String serviceProviderType,
    required String serviceProviderId,
    required String appointmentDate,
    required String appointmentTime,
    required String status,
    required BuildContext context,
  }) async {
    try {
      // Payload
      final payload = {
        "patient": {
          "id": patientId,
          "email": patientEmail,
          "full_name": patientFullName,
        },
        "service_provider_type": serviceProviderType,
        "service_provider_id": serviceProviderId,
        "appointment_date": appointmentDate,
        "appointment_time": appointmentTime,
        "status": status,
      };

      debugPrint("🟢 [CREATE] Reservation Payload: $payload");

      // Retrieve token from TokenProvider or SharedPreferences
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      String? token = tokenProvider.accessToken;

      if (token == null || token.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString("Login_access_token");
      }

      if (token == null || token.isEmpty) {
        throw Exception("Access token is missing. Please login again.");
      }

      // Build Dio with the token
      final dio = Dio();
      debugPrint("🔐 [CREATE] Using token: $token");
      dio.options.headers["Authorization"] = "JWT $token";

      // POST the payload
      final response = await dio.post(
        "https://racheeta.pythonanywhere.com/reservations/",
        data: payload,
      );

      debugPrint("📡 [CREATE] Response status: ${response.statusCode}");

      if (response.statusCode == 201) {
        final reservationData = response.data;
        debugPrint("✅ [CREATE] Reservation created: $reservationData");

        // Field-by-field safe parsing
        try {
          reservationData.forEach((key, value) {
            debugPrint('  🔍 Field: $key => $value (${value.runtimeType})');
          });
        } on TypeError catch (e, s) {
          debugPrint("❌ [CREATE] TypeError during parsing: $e");
          debugPrint("🧩 Stack trace: $s");
          return null;
        } on FormatException catch (e, s) {
          debugPrint("❌ [CREATE] FormatException during parsing: $e");
          debugPrint("🧩 Stack trace: $s");
          return null;
        } catch (e, s) {
          debugPrint("❌ [CREATE] Unexpected error during parsing: $e");
          debugPrint("🧩 Stack trace: $s");
          return null;
        }
      } else {
        debugPrint(
            "❗ [CREATE] Failed with status ${response.statusCode}: ${response.data}");
        return null;
      }
    } catch (e, s) {
      debugPrint("🔥 [CREATE] Exception caught: $e");
      debugPrint("🧩 Stack trace: $s");
      return null;
    }
  }

  // ------------------------------------------------
  // /me/ => PARTIAL reservations
  // ------------------------------------------------
  Future<void> fetchMeAndReservations(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("Login_access_token") ?? '';

      final dio = Dio();
      dio.options.headers["Authorization"] = "JWT $token";

      final response = await dio.get("https://racheeta.pythonanywhere.com/me/");
      _meData = response.data;
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching me data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ في جلب البيانات')),
      );
    }
  }

  // ------------------------------------------------
  // updateReservationStatusdashboard
  // -> Called from your UI to PATCH a reservation
  // ------------------------------------------------
  Future<void> updateReservationStatusdashboard({
    required BuildContext context,
    required String reservationId,
    required String newStatus,
    required DateTime pickedDateTime,
  }) async {
    try {
      // Format the date/time for the request payload.
      final appointmentDate =
          "${pickedDateTime.year}-${pickedDateTime.month.toString().padLeft(2, '0')}-${pickedDateTime.day.toString().padLeft(2, '0')}";
      final appointmentTime =
          "${pickedDateTime.hour.toString().padLeft(2, '0')}:${pickedDateTime.minute.toString().padLeft(2, '0')}:00";

      final requestBody = {
        "status": newStatus.toUpperCase(),
        "appointment_date": appointmentDate,
        "appointment_time": appointmentTime,
      };

      // Retrieve token from provider or SharedPreferences.
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      String? token = tokenProvider.accessToken;
      if (token == null || token.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString("Login_access_token");
      }
      if (token == null || token.isEmpty) {
        throw Exception("No valid access token found. Please login again.");
      }

      // Create a Dio instance with the correct authorization header.
      final dio = Dio();
      dio.options.headers["Authorization"] = "JWT $token";
      final url =
          "https://racheeta.pythonanywhere.com/reservations/$reservationId/";

      debugPrint(">>> [UPDATE] PATCH $url");
      debugPrint(">>> [UPDATE] Payload: $requestBody");

      final response = await dio.patch(url, data: requestBody);

      if (response.statusCode == 200) {
        debugPrint(
            ">>> [UPDATE] Reservation updated successfully. New status: ${newStatus.toUpperCase()}");

        if (newStatus.toUpperCase() == 'CANCELLED') {
          // Remove the cancelled appointment immediately from the list.
          removeReservationById(reservationId);
        } else {
          // For other statuses, re-fetch updated reservations if needed.
          await fetchMyFullReservations(context);
        }
      } else {
        debugPrint(
            ">>> [UPDATE] Failed to update reservation: ${response.data}");
      }
    } catch (e) {
      debugPrint(">>> [UPDATE] Error updating reservation: $e");
    }
  }

  /// Helper method to remove a reservation by its ID.
  void removeReservationById(String reservationId) {
    _fullReservations.removeWhere((res) => res.id == reservationId);
    notifyListeners();
  }

  // ------------------------------------------------
  // Another method: updateReservationStatus (using ApiClient)
  // Only use if you want the Retrofit approach
  // ------------------------------------------------
  Future<void> updateReservationStatus({
    required String reservationId,
    required String newStatus,
    required DateTime pickedDateTime,
  }) async {
    try {
      final appointmentDate =
          "${pickedDateTime.year}-${pickedDateTime.month.toString().padLeft(2, '0')}-${pickedDateTime.day.toString().padLeft(2, '0')}";
      final appointmentTime =
          "${pickedDateTime.hour.toString().padLeft(2, '0')}:${pickedDateTime.minute.toString().padLeft(2, '0')}:00";

      final requestBody = {
        "status": newStatus.toUpperCase(),
        "appointment_date": appointmentDate,
        "appointment_time": appointmentTime,
      };

      debugPrint(">>> [RETROFIT] updateReservation call: $requestBody");
      final updatedReservation =
      await _apiClient.updateReservation(reservationId, requestBody);

      debugPrint(
          ">>> [RETROFIT] Response from server: ${updatedReservation.toJson()}");

      final index = _reservations.indexWhere((res) => res.id == reservationId);
      if (index != -1) {
        _reservations[index] = updatedReservation;
        notifyListeners();
      }
    } catch (e) {
      debugPrint(">>> [RETROFIT] Error updating reservation: $e");
    }
  }

  // ------------------------------------------------
  // Sorting
  // ------------------------------------------------
  void sortReservations(String column, bool ascending) {
    _reservations.sort((a, b) {
      final aValue = a.toJson()[column] ?? '';
      final bValue = b.toJson()[column] ?? '';

      if (aValue is num && bValue is num) {
        return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
      } else if (aValue is String && bValue is String) {
        return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
      } else {
        return 0;
      }
    });
    notifyListeners();
  }

  // ------------------------------------------------
  // fetchReservationById
  // ------------------------------------------------
  Future<ReservationModel> fetchReservationById(
      String reservationId, BuildContext context) async {
    try {
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      String? token = tokenProvider.accessToken;

      if (token == null || token.isEmpty) {
        throw Exception("Access token is missing. Please login again.");
      }
      debugPrint(">>> [BY ID] Access token: $token");

      final dio = Dio();
      dio.options.headers["Authorization"] =
          token; // Possibly "JWT $token" needed

      final apiClient = ApiClient(dio);
      final reservation = await apiClient.fetchReservationById(reservationId);

      debugPrint(">>> [BY ID] Fetched reservation: ${reservation.toJson()}");
      return reservation;
    } catch (e) {
      debugPrint(">>> [BY ID] Error: $e");
      throw Exception("Failed to fetch reservation by ID");
    }
  }

  // ------------------------------------------------
  // fetchReservationsForPatientAndDoctor
  // ------------------------------------------------
  Future<List<ReservationModel>> fetchReservationsForPatientAndDoctor({
    required String patientId,
    required String doctorId,
    required reservationId,
  }) async {
    try {
      final reservations =
      await _apiClient.fetchReservationsForPatientAndDoctor(
        patientId,
        doctorId,
      );
      return reservations;
    } catch (e) {
      debugPrint(">>> [PATIENT/DOC] Error: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchHspUserData(
      String hspType, String hspId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("Login_access_token");
      if (token == null) return null;

      final dio = Dio();
      dio.options.headers["Authorization"] = "JWT $token";

      // Normalize the service provider type.
      String normalizedType(String type) {
        switch (type.toLowerCase()) {
          case "doctor":
            return "doctor";
          case "nurse":
            return "nurse";
          case "therapist":
            return "therapist";
          case "pharmacy":
          case "pharmacist":
            return "pharmacist";
          case "hospital":
            return "hospital";
          case "beautycenter":
          case "beauty_center":
          case "beauty center":
            return "beauty_center";
          case "labrotary":
          case "laboratory":
            return "laboratory";
          case "medicalcenter":
          case "medical_center":
            return "medical_center";
          case "clinic":
            return "clinic";
          default:
            return type.toLowerCase();
        }
      }

      final normType = normalizedType(hspType);

      String endpoint = '';
      switch (normType) {
        case "doctor":
          endpoint = "/doctor/$hspId/";
          break;
        case "nurse":
          endpoint = "/nurses/$hspId/";
          break;
        case "therapist":
          endpoint = "/therapists/$hspId/";
          break;
        case "pharmacist":
          endpoint = "/pharmacists/$hspId/";
          break;
        case "hospital":
          endpoint = "/hospitals/$hspId/";
          break;
        case "beauty_center":
          endpoint = "/beauty-centers/$hspId/";
          break;
        case "laboratory":
          endpoint = "/laboratories/$hspId/";
          break;
        case "clinic":
          endpoint = "/clinics/$hspId/";
          break;
        case "medical_center":
          endpoint = "/medical-centers/$hspId/";
          break;
        default:
          debugPrint("🔴 Unknown service_provider_type: $hspType");
          return null;
      }

      final url = "https://racheeta.pythonanywhere.com$endpoint";
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        // For doctor, nurse, and therapist, the key "user" holds the details.
        if (normType == "doctor" ||
            normType == "nurse" ||
            normType == "therapist") {
          return response.data["user"];
        } else {
          // For other types, return the entire object.
          return response.data;
        }
      } else {
        debugPrint("❌ Error fetching HSP user data: ${response.data}");
        return null;
      }
    } catch (e) {
      debugPrint("🔥 Error in fetchHspUserData($hspType): $e");
      return null;
    }
  }

  // ------------------------------------------------
  // fetchReservationsByUser
  // (works if user is "patient" I guess)
  // ------------------------------------------------
  Future<List<ReservationModel>> fetchReservationsByUser(
      String userId,
      BuildContext context,
      ) async {
    try {
      // 1. Get the auth token
      String? token;
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      token = tokenProvider.accessToken;

      if (token == null || token.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString("Login_access_token");
      }
      if (token == null || token.isEmpty) {
        throw Exception("No access token found. Please log in again.");
      }

      // 2. Make the request
      final dio = Dio();
      dio.options.headers["Authorization"] = "JWT $token";
      final response =
      await dio.get("https://racheeta.pythonanywhere.com/reservations/");

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // Parse all reservations
        final allReservations =
        data.map((json) => ReservationModel.fromJson(json)).toList();

        // 3. Filter to current user
        final filteredReservations = allReservations.where((r) {
          final patientId = r.patient?.id?.trim().toLowerCase() ?? "";
          final currentUserId = userId.trim().toLowerCase();
          return patientId == currentUserId;
        }).toList();

        // 4. Show only same-day or future (ignoring time for same-day)
        final now = DateTime.now();
        final todayMidnight = DateTime(now.year, now.month, now.day);

        final upcomingReservations = filteredReservations.where((r) {
          // Must have both date & time
          if (r.appointmentDate == null || r.appointmentTime == null) {
            return false;
          }

          // Combine date and time
          final fullDateTimeStr = '${r.appointmentDate} ${r.appointmentTime}';
          final apptDateTime = DateTime.tryParse(fullDateTimeStr);

          if (apptDateTime == null) return false;

          // If same calendar day (year, month, day), include it
          final sameDay = (apptDateTime.year == now.year &&
              apptDateTime.month == now.month &&
              apptDateTime.day == now.day);

          // If it's the same day OR it's in the future
          return sameDay || apptDateTime.isAfter(now);
        }).toList();

        // 5. Optionally fetch additional data for each reservation
        for (var reservation in upcomingReservations) {
          if (reservation.serviceProviderId != null &&
              reservation.serviceProviderType != null) {
            final hspUser = await fetchHspUserData(
              reservation.serviceProviderType!,
              reservation.serviceProviderId!,
            );
            reservation.hspUser = hspUser;
            debugPrint(
                "Fetched HSP data for type=${reservation.serviceProviderType}: $hspUser");
          }
        }

        return upcomingReservations;
      }

      // 6. Handle 401 (token expired)
      else if (response.statusCode == 401) {
        final refreshed = await _refreshToken(context);
        if (refreshed) {
          return fetchReservationsByUser(userId, context);
        } else {
          throw Exception("Failed to refresh token. Please log in again.");
        }
      }

      // 7. Other errors
      else {
        throw Exception("Failed to fetch reservations: ${response.data}");
      }
    } catch (e) {
      debugPrint(">>> [BY USER] Error: $e");
      return [];
    }
  }

  // ------------------------------------------------
  // REFRESH TOKEN
  // ------------------------------------------------
  Future<bool> _refreshToken(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString("refresh_token");

      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint(">>> [REFRESH] No refresh token found.");
        return false;
      }

      final dio = Dio();
      final response = await dio.post(
        "https://racheeta.pythonanywhere.com/token/refresh/",
        data: {"refresh": refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data["access"];
        debugPrint(">>> [REFRESH] New Access Token: $newAccessToken");

        // Update SharedPreferences
        await prefs.setString("Login_access_token", newAccessToken);

        // Update TokenProvider
        final tokenProvider =
        Provider.of<TokenProvider>(context, listen: false);
        tokenProvider.updateToken(newAccessToken);

        return true;
      } else {
        debugPrint(">>> [REFRESH] Failed: ${response.data}");
        return false;
      }
    } catch (e) {
      debugPrint(">>> [REFRESH] Error: $e");
      return false;
    }
  }

  // ------------------------------------------------
  // FULL Reservation approach
  // /me/ => IDs => GET each ID => store _fullReservations
  // ------------------------------------------------
  // 1) fetchMyReservationIds
  Future<List<String>> fetchMyReservationIds(BuildContext context) async {
    try {
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      String? token = tokenProvider.accessToken;

      if (token == null || token.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString("Login_access_token");
      }

      if (token == null || token.isEmpty) {
        throw Exception("No valid access token found. Please login again.");
      }
      debugPrint(">>> [FULL] fetchMyReservationIds. token: $token");

      final dio = Dio();
      dio.options.headers["Authorization"] = "JWT $token";

      final response = await dio.get("https://racheeta.pythonanywhere.com/me/");

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> myReservations = data["my_reservations"] ?? [];
        final List<String> reservationIds =
        myReservations.map((resJson) => resJson["id"] as String).toList();

        debugPrint(">>> [FULL] Found IDs: $reservationIds");
        return reservationIds;
      } else {
        debugPrint(">>> [FULL] Failed /me/: ${response.data}");
        throw Exception("Error fetching /me/. Code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint(">>> [FULL] Error in fetchMyReservationIds: $e");
      return [];
    }
  }

  // 2) fetchOneReservationById
  Future<ReservationModel> fetchOneReservationById(
      String reservationId, BuildContext context) async {
    try {
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      String? token = tokenProvider.accessToken;

      if (token == null || token.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString("Login_access_token");
      }

      if (token == null || token.isEmpty) {
        throw Exception("No valid access token found. Please login again.");
      }
      debugPrint(
          ">>> [FULL] fetchOneReservationById($reservationId) with token: $token");

      final dio = Dio();
      dio.options.headers["Authorization"] = "JWT $token";

      final url =
          "https://racheeta.pythonanywhere.com/reservations/$reservationId/";
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final json = response.data;
        return ReservationModel.fromJson(json);
      } else {
        debugPrint(
            ">>> [FULL] Failed to fetch ID=$reservationId: ${response.data}");
        throw Exception("Error fetching reservation by ID");
      }
    } catch (e) {
      debugPrint(">>> [FULL] Error: $e");
      throw Exception("Error fetching reservation by ID");
    }
  }

  // 3) fetchMyFullReservations => calls the above two in sequence
  Future<void> fetchMyFullReservations(BuildContext context) async {
    try {
      final ids = await fetchMyReservationIds(context);
      debugPrint(">>> [FULL] Reservation IDs from /me/: $ids");

      final fetchFutures =
      ids.map((id) => fetchOneReservationById(id, context));
      final fetched = await Future.wait(fetchFutures);

      // _fullReservations = fetched;
      _fullReservations = fetched
          .where((r) => (r.status ?? '').toUpperCase() != 'CANCELLED')
          .toList(); // 🚫 drop cancelled here as well
      notifyListeners();
      debugPrint(
          ">>> [FULL] Loaded ${_fullReservations.length} reservations via /me/ + ID calls.");
    } catch (e) {
      debugPrint(">>> [FULL] Error in fetchMyFullReservations: $e");
    }
  }
  Future<void> fetchReservationsForDoctor(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final doctorId = prefs.getString('doctor_id');

      if (doctorId == null || doctorId.isEmpty) {
        debugPrint("❌ No doctor_id found in SharedPreferences.");
        return;
      }

      final token = prefs.getString("Login_access_token");
      final dio = Dio()
        ..options.headers['Authorization'] = 'JWT $token';

      final response = await dio.get(
        'https://racheeta.pythonanywhere.com/reservations/',
        queryParameters: {'service_provider_id': doctorId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        _fullReservations = data
            .map((j) => ReservationModel.fromJson(j))
            .where((r) => (r.status ?? '').toUpperCase() != 'CANCELLED')
            .toList();

        notifyListeners();
        debugPrint("✅ Doctor Reservations Fetched: ${_fullReservations.length}");
      } else {
        debugPrint("❌ Failed to fetch doctor reservations: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🔥 Exception in fetchReservationsForDoctor: $e");
    }
  }

  void setMeData(Map<String, dynamic> data) {
    _meData = data;
    notifyListeners();
  }

// ---------------------------------------------------------------------------
// NEW: fetchAllReservationsForServiceProvider
// ---------------------------------------------------------------------------
// In ReservationRetroDisplayGetProvider:

  /// ---------------------------------------------------------------------------
  /// NEW: fetchAllReservationsForServiceProvider (with debug dumps)
  /// ---------------------------------------------------------------------------
  /// ---------------------------------------------------------------------------
  /// NEW: fetchAllReservationsForServiceProvider (with debug dumps)
  /// ---------------------------------------------------------------------------
  Future<List<ReservationModel>> fetchAllReservationsForServiceProvider(
      String hspId,
      BuildContext context,
      ) async {
    try {
      final token = Provider.of<TokenProvider>(context, listen: false).accessToken!;
      final dio = Dio()..options.headers['Authorization'] = 'JWT $token';

      debugPrint('▶️ [FETCH ALL] calling /reservations/?service_provider_id=$hspId');
      final resp = await dio.get(
        'https://racheeta.pythonanywhere.com/reservations/',
        queryParameters: {'service_provider_id': hspId},
      );

      // 1) Dump raw JSON list
      final raw = resp.data;
      if (raw is List) {
        debugPrint('▶️ [FETCH ALL] raw JSON array length=${raw.length}');
        for (var i = 0; i < raw.length; i++) {
          debugPrint('  ▶️ [FETCH ALL] item[$i]: ${raw[i]}');
        }
      } else {
        debugPrint('⚠️ [FETCH ALL] Expected List but got: ${raw.runtimeType}');
      }

      if (resp.statusCode == 200 && raw is List) {
        return raw.map((j) {
          debugPrint('  ▶️ [FETCH ALL] parsing JSON → $j');
          final model = ReservationModel.fromJson(j as Map<String, dynamic>);
          debugPrint('  ▶️ [FETCH ALL] parsed model.id = ${model.id}');
          return model;
        }).toList();
      } else {
        throw Exception('Status ${resp.statusCode}');
      }
    } catch (e, st) {
      debugPrint('🔥 [FETCH ALL] Exception: $e\n$st');
      return [];
    }
  }





// New helper: merge the new reservations with the existing list.
  void mergeReservations(List<ReservationModel> newList) {
    // Create a map from the current list for quick lookup.
    final Map<String, ReservationModel> byId = {
      for (final r in _fullReservations) r.id!: r,
    };

    // Add or update with new reservations, but only if they are NOT CANCELLED.
    for (final res in newList) {
      if ((res.status ?? '').toUpperCase() != 'CANCELLED') {
        byId[res.id!] = res;
      } else {
        // If the new reservation is CANCELLED, ensure it is not kept.
        byId.remove(res.id);
      }
    }

    // Alternatively, you could merge first and then remove cancelled ones:
    // _fullReservations = [...byId.values, ...newList];
    // _fullReservations.removeWhere((r) => (r.status ?? '').toUpperCase() == 'CANCELLED');

    _fullReservations = byId.values.toList();
    notifyListeners();
  }
}
