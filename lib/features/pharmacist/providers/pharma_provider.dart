import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../doctors/models/user_model.dart';
import '../services/api_client.dart';
import '../models/pharma_model.dart';

class PharmaRetroDisplayGetProvider with ChangeNotifier {
  late ApiClient _apiClient;
  Dio dio = Dio();

  // Store the local list of PharmaModel
  List<PharmaModel> _pharmacies = [];
  List<PharmaModel> get pharmacies => _pharmacies;
// Add these two lines to make /me/ available
  Map<String, dynamic>? _meData;
  Map<String, dynamic>? get meData => _meData;

  PharmaRetroDisplayGetProvider(String token) {
    if (token.isEmpty) {
      dio.options.headers.remove("Authorization");
    } else {
      dio.options.headers["Authorization"] = "JWT $token";
    }
    print("Initializing PharmaRetroDisplayGetProvider with token: $token");
    _apiClient = ApiClient(dio);
  }
  Future<void> updateToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", newToken);
    dio.options.headers["Authorization"] = "JWT $newToken";
    debugPrint("TherapistRetroDisplayGetProvider token updated: $newToken");
    notifyListeners();
  }
  // ---------------------
  // (B) CREATE PHARMACY
  // ---------------------
  Future<PharmaModel?> createPharmacy({
    required UserModel userModel,
    required String pharmacyName,
    required String bio,
    required String address,
    required String gpsLocation,
    required bool sentinel,
  }) async {
    print(">>> [createPharmacy] Starting pharmacy creation...");

    if (userModel.id == null || userModel.id!.isEmpty) {
      throw ArgumentError('Cannot create pharmacy without a created user id');
    }

    // (B.2) Build the top-level payload
    final Map<String, dynamic> payload = {
      "user": {"id": userModel.id},
      "pharmacy_name": pharmacyName,
      "bio": bio,
      "address": address,
      "gps_location": gpsLocation,
      "sentinel": sentinel,
    };

    print(">>> [createPharmacy] Payload: $payload");

    try {
      // (B.3) Check the actual Authorization header in `this.dio`
      final authHeader = dio.options.headers["Authorization"];
      print(">>> [DEBUG] Checking Authorization: $authHeader");

      // (B.4) Create pharmacy via your ApiClient
      final PharmaModel response = await _apiClient.createPharmacy(payload);

      print(
          ">>> [createPharmacy] Pharmacy created successfully: ${response.toJson()}");

      // Update local state
      _pharmacies.add(response);
      notifyListeners();

      return response;
    } catch (e) {
      // If DioError => log it
      if (e is DioError) {
        print(">>> [DEBUG] DioError in createPharmacy:");
        print(">>> [DEBUG] Status: ${e.response?.statusCode}");
        print(">>> [DEBUG] Data: ${e.response?.data}");
      } else {
        print(">>> [DEBUG] Unexpected error: $e");
      }
      rethrow; // Let the caller handle it
    }
  }

  // ---------------------
  // (C) FETCH PHARMACIES
  // ---------------------
  Future<List<PharmaModel>> fetchPharmacies() async {
    try {
      final response = await _apiClient.fetchPharmacies();
      _pharmacies = response;
      notifyListeners();
      return response;
    } catch (e) {
      print("Error fetching pharmacies: $e");
      return [];
    }
  }

  // ---------------------
  // (D) UPDATE PHARMACY
  // ---------------------
  Future<PharmaModel?> updatePharmacy({
    required String id,
    String? pharmacyName,
    String? bio,
    bool? advertise,
    String? address,
    String? gpsLocation,
    String? advertisePrice,
    String? advertiseDuration,
  }) async {
    try {
      final pharmacyData = {
        "pharmacy_name": pharmacyName,
        "bio": bio,
        "advertise": advertise,
        "address": address,
        "gps_location": gpsLocation,
        "advertise_price": advertisePrice,
        "advertise_duration": advertiseDuration,
      };
      pharmacyData.removeWhere((key, value) => value == null);

      print(">>> [updatePharmacy] Payload: $pharmacyData");

      final response = await _apiClient.updatePharmacy(id, pharmacyData);

      final index = _pharmacies.indexWhere((p) => p.id == id);
      if (index != -1) {
        _pharmacies[index] = response;
        notifyListeners();
      }

      print(">>> [updatePharmacy] Pharmacy updated: ${response.toJson()}");
      return response;
    } catch (e) {
      print("Error updating pharmacy: $e");
      return null;
    }
  }

  // ---------------------
  // (E) DELETE PHARMACY
  // ---------------------
  Future<void> deletePharmacy(String id) async {
    try {
      await _apiClient.deletePharmacy(id);
      _pharmacies.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      print("Error deleting pharmacy: $e");
    }
  }

  Future<void> fetchMe() async {
    try {
      final response = await dio.get("https://racheeta.pythonanywhere.com/me/");
      if (response.statusCode == 200) {
        _meData = response.data;
        notifyListeners();
      } else {
        throw Exception("Failed to fetch /me/ data");
      }
    } catch (e) {
      debugPrint("Error in PharmaRetroDisplayGetProvider.fetchMe(): $e");
      rethrow;
    }
  }

  Future<void> updateAdvertisement({
    required String pharmaId,
    required bool advertise,
    required String advertisePrice,
    required String advertiseDuration,
  }) async {
    // Ensure medicalcenterId is not empty
    if (pharmaId.isEmpty) {
      print(
          '>>> [Update Advertisement] ❌ Error: ’Medical Center ID is EMPTY! Aborting request.');
      return;
    }

    print('>>> [Update Advertisement] 🏥 PharmaId ID: $pharmaId');

    final requestBody = {
      "advertise": advertise,
      "advertise_price": advertisePrice,
      "advertise_duration": advertiseDuration,
    };

    print(
        '>>> [Update Advertisement] 📡 Sending Request Payload: $requestBody');

    try {
      // Ensure the PATCH request includes the correct medicalcenterId
      final url =
          'https://racheeta.pythonanywhere.com/medical-centers/$pharmaId/';

      final response = await dio.patch(url, data: requestBody);

      if (response.statusCode == 200) {
        print(
            '>>> [Update Advertisement] ✅ Successfully updated advertisement');
      } else {
        print(
            '>>> [Update Advertisement] ❌ Failed with status: ${response.statusCode}');
        throw Exception('Failed to update advertisement');
      }
    } catch (e) {
      print('>>> [Update Advertisement] ❌ Error occurred: $e');
      if (e is DioException) {
        print('>>> [Update Advertisement] 🛑 DioError Details:');
        print('    🛠️ Request URL: ${e.requestOptions.uri}');
        print('    🛠️ Request Headers: ${e.requestOptions.headers}');
        print('    🛠️ Request Data: ${e.requestOptions.data}');
        print('    ❌ Response Data: ${e.response?.data}');
        print('    🚨 Status Code: ${e.response?.statusCode}');
      }
    }
  }

  /// Check if a nurse has an active advertisement
  Future<Map<String, dynamic>?> getActiveAd(String pharmaId) async {
    try {
      final PharmaModel pharmacy = await _apiClient.getPharmacyById(pharmaId);

      debugPrint(">>> [getActiveAd] Pharmacy fetched: ${pharmacy.toJson()}");

      if (pharmacy.advertise == true) {
        final DateTime startDate = DateTime.parse(
            pharmacy.createDate ?? DateTime.now().toIso8601String());
        final DateTime endDate = DateTime.parse(
            pharmacy.updateDate ?? DateTime.now().toIso8601String());

        debugPrint(">>> [getActiveAd] Active advertisement found with dates.");

        return {
          'duration': pharmacy.advertiseDuration ?? 'N/A',
          'start_date': startDate,
          'end_date': endDate,
        };
      }

      debugPrint(">>> [getActiveAd] No active advertisement for nurse.");
      return null;
    } catch (e) {
      debugPrint(">>> [getActiveAd] Error: $e");
      return null;
    }
  }
}
