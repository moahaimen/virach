import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:racheeta/features/doctors/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import '../models/therapist_model.dart';

class TherapistRetroDisplayGetProvider with ChangeNotifier {
  late ApiClient _apiClient;
  Dio dio = Dio();

  List<TherapistModel> _therapists = []; // List to store fetched therapists
// Add these two lines to make /me/ available
  Map<String, dynamic>? _meData;
  Map<String, dynamic>? get meData => _meData;

  TherapistRetroDisplayGetProvider(String token) {
    dio.options.headers["Authorization"] = "JWT $token";
    _apiClient = ApiClient(dio);
  }

  List<TherapistModel> get therapists => _therapists;
  Future<void> updateToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", newToken);
    dio.options.headers["Authorization"] = "JWT $newToken";
    debugPrint("TherapistRetroDisplayGetProvider token updated: $newToken");
    notifyListeners();
  }
  /// Create Therapist
  Future<TherapistModel?> createTherapist({
    required UserModel userModel,
    required String specialty,
    required String bio,
    required String address,
    required String availabilityTime,
    bool advertise = false,
    String? advertisePrice,
    String? advertiseDuration,
  }) async {
    print(">>> [createTherapist] Starting therapist creation...");

    final Map<String, dynamic> userPayload = {
      "id": userModel.id,
      "email": userModel.email,
      "full_name": userModel.fullName,
      "role": userModel.role,
      "profile_image": userModel.profileImage,
      "gps_location": userModel.gpsLocation,
      "phone_number": userModel.phoneNumber,
      "is_active": userModel.isActive ?? true,
      "is_staff": userModel.isStaff ?? false,
      "gender": userModel.gender,
      "firebase_uid": userModel.firebaseUid,
      "create_date": userModel.createDate,
      "update_date": userModel.updateDate,
    };

    final payload = {
      "user": userPayload,
      "specialty": specialty,
      "bio": bio,
      "address": address,
      "availability_time": availabilityTime,
      "advertise": advertise,
      "advertise_price": advertisePrice,
      "advertise_duration": advertiseDuration,
    };

    print(">>> [createTherapist] Payload: $payload");

    try {
      final response = await _apiClient.createTherapist(payload);
      print(">>> [createTherapist] Server Response: ${response.toJson()}");
      return response;
    } catch (e) {
      if (e is DioError) {
        print(">>> [DEBUG] DioError occurred:");
        print(">>> [DEBUG] Status Code: ${e.response?.statusCode}");
        print(">>> [DEBUG] Response Data: ${e.response?.data}");
      } else {
        print(">>> [DEBUG] Unexpected error during createTherapist: $e");
      }
      return null;
    }
  }

  /// Fetch Therapists
  Future<List<TherapistModel>> fetchTherapists() async {
    try {
      final response = await _apiClient.fetchTherapists();
      _therapists = response;
      notifyListeners();
      return response;
    } catch (e) {
      print("Error fetching therapists: $e");
      return [];
    }
  }

  /// Update Therapist
  Future<TherapistModel?> updateTherapist({
    required String id,
    String? specialty,
    String? bio,
    bool? advertise,
    String? address,
    String? availabilityTime,
    String? advertisePrice,
    String? advertiseDuration,
    String? profileImage,
  }) async {
    try {
      final therapistData = {
        "specialty": specialty,
        "bio": bio,
        "advertise": advertise,
        "address": address,
        "availability_time": availabilityTime,
        "advertise_price": advertisePrice,
        "advertise_duration": advertiseDuration,
        "profile_image": profileImage,
      };
      therapistData.removeWhere((key, value) => value == null);

      final response = await _apiClient.updateTherapist(id, therapistData);
      final index = _therapists.indexWhere((therapist) => therapist.id == id);
      if (index != -1) {
        _therapists[index] = response;
        notifyListeners();
      }
      return response;
    } catch (e) {
      print("Error updating therapist: $e");
      return null;
    }
  }

  /// Delete Therapist
  Future<void> deleteTherapist(String id) async {
    try {
      await _apiClient.deleteTherapist(id);
      _therapists.removeWhere((therapist) => therapist.id == id);
      notifyListeners();
    } catch (e) {
      print("Error deleting therapist: $e");
    }
  }

  Future<void> updateAdvertisement({
    required String therapistId,
    required bool advertise,
    required String advertisePrice,
    required String advertiseDuration,
  }) async {
    debugPrint('>>> [updateAdvertisement] therapistId: $therapistId');

    final payload = {
      'advertise': advertise,
      'advertise_price': advertisePrice,
      'advertise_duration': advertiseDuration,
    };

    try {
      // 1) Load token from SharedPreferences (or from wherever you store it)
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) {
        throw Exception('No token found in SharedPreferences');
      }

      // 2) Create a fresh Dio instance or reuse the one in your provider
      final Dio dio = Dio();
      dio.options.headers['Authorization'] = 'JWT $token';

      // 3) Perform PATCH request (notice the URL is /doctors/{id}/, not /doctor/{id}/advertise/)
      final url = 'https://racheeta.pythonanywhere.com/therapists/$therapistId/';
      debugPrint('>>> [updateAdvertisement] PATCH URL: $url');
      debugPrint('>>> [updateAdvertisement] Payload: $payload');

      final response = await dio.patch(url, data: payload);

      if (response.statusCode == 200) {
        debugPrint(
            '>>> [updateAdvertisement] Successfully updated advertisement');
      } else {
        debugPrint(
            '>>> [updateAdvertisement] Non-200 status: ${response.statusCode}');
        throw Exception('Failed to update advertisement');
      }
    } catch (e) {
      debugPrint('>>> [updateAdvertisement] Error: $e');
      if (e is DioError) {
        debugPrint('    Response data: ${e.response?.data}');
        debugPrint('    Status code: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  /// Check if a nurse has an active advertisement
  Future<Map<String, dynamic>?> getActiveAd(String therapistId) async {
    try {
      // Call the API to get the therapist by their ID.
      final TherapistModel therapist =
          await _apiClient.getTherapistById(therapistId);
      debugPrint(">>> [getActiveAd] Therapist fetched: ${therapist.toJson()}");

      // Check if the therapist has an active advertisement.
      if (therapist.advertise == true) {
        // Safely parse the start and end dates.
        // If the dates are null, we default to DateTime.now() to avoid errors.
        final DateTime startDate = therapist.createDate != null
            ? DateTime.parse(therapist.createDate!)
            : DateTime.now();
        final DateTime endDate = therapist.updateDate != null
            ? DateTime.parse(therapist.updateDate!)
            : DateTime.now();

        debugPrint(">>> [getActiveAd] Active advertisement found with dates.");

        return {
          'duration': therapist.advertiseDuration ?? 'N/A',
          'start_date': startDate,
          'end_date': endDate,
        };
      }

      debugPrint(">>> [getActiveAd] No active advertisement for therapist.");
      return null;
    } catch (e) {
      debugPrint(">>> [getActiveAd] Error: $e");
      return null;
    }
  }

  Future<void> fetchMe() async {
    try {
      final response = await dio.get("https://racheeta.pythonanywhere.com/me/");
      if (response.statusCode == 200) {
        _meData = response.data;
        notifyListeners();
      } else {
        throw Exception(
            "Failed to fetch /me/ data: ${response.statusCode} ${response.data}");
      }
    } catch (e) {
      debugPrint("Error in TherapistRetroDisplayGetProvider.fetchMe(): $e");
      rethrow;
    }
  }
}
