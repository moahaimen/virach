import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../doctors/models/user_model.dart';
import '../services/api_client.dart';
import '../models/nurse_model.dart';

class NurseRetroDisplayGetProvider with ChangeNotifier {
  late ApiClient _apiClient;
  Dio dio = Dio();
  List<NurseModel> _nurses = []; // List to store fetched nurses
  // Add these two lines to make /me/ available
  Map<String, dynamic>? _meData;
  Map<String, dynamic>? get meData => _meData;

  NurseRetroDisplayGetProvider(String token) {
    dio.options.headers["Authorization"] = "JWT $token";
    _apiClient = ApiClient(dio);
  }

  List<NurseModel> get nurses => _nurses;

  /// Create Nurse
  Future<NurseModel?> createNurse({
    required UserModel userModel,
    required String specialty,
    required String degree,
    required String bio,
    required String address,
    required String availabilityTime,
  }) async {
    print(">>> [createNurse] Starting nurse creation...");

    if (userModel.id == null || userModel.id!.isEmpty) {
      throw ArgumentError('Cannot create nurse without a created user id');
    }

    final Map<String, dynamic> payload = {
      "user": {"id": userModel.id},
      "specialty": specialty,
      "degree": degree,
      "bio": bio,
      "address": address,
      "availability_time": availabilityTime,
    };

    print(">>> [createNurse] Payload: $payload");

    try {
      final NurseModel response = await _apiClient.createNurse(payload);
      print(
          ">>> [createNurse] Nurse created successfully: ${response.toJson()}");
      _nurses.add(response);
      notifyListeners();
      return response;
    } catch (e) {
      if (e is DioError) {
        print(">>> [DEBUG] DioError occurred during createNurse:");
        print(
            ">>> [DEBUG] Error Response Status Code: ${e.response?.statusCode}");
        print(">>> [DEBUG] Error Response Headers: ${e.response?.headers}");
        print(">>> [DEBUG] Error Response Data: ${e.response?.data}");
      } else {
        print(">>> [DEBUG] Unexpected error during createNurse: $e");
      }
      rethrow;
    }
  }

  /// Fetch Nurses
  Future<List<NurseModel>> fetchNurses() async {
    print(">>> [fetchNurses] Fetching nurses...");
    try {
      final response = await _apiClient.fetchNurses();
      _nurses = response;
      notifyListeners();
      return response;
    } catch (e) {
      print("Error fetching nurses: $e");
      return [];
    }
  }

  /// Update Nurse
  Future<NurseModel?> updateNurse({
    required String id,
    String? specialty,
    String? degree,
    String? bio,
    String? address,
    String? availabilityTime,
  }) async {
    print(">>> [updateNurse] Updating nurse with ID: $id...");
    try {
      final nurseData = {
        "specialty": specialty,
        "degree": degree,
        "bio": bio,
        "address": address,
        "availability_time": availabilityTime,
      };
      nurseData.removeWhere((key, value) => value == null);

      final response = await _apiClient.updateNurse(id, nurseData);
      final index = _nurses.indexWhere((nurse) => nurse.id == id);
      if (index != -1) {
        _nurses[index] = response;
        notifyListeners();
      }
      return response;
    } catch (e) {
      print("Error updating nurse: $e");
      return null;
    }
  }

  /// Delete Nurse
  Future<void> deleteNurse(String id) async {
    print(">>> [deleteNurse] Deleting nurse with ID: $id...");
    try {
      await _apiClient.deleteNurse(id);
      _nurses.removeWhere((nurse) => nurse.id == id);
      notifyListeners();
    } catch (e) {
      print("Error deleting nurse: $e");
    }
  }

  /// Token Management
  Future<void> updateToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", newToken);

    dio.options.headers["Authorization"] = "JWT $newToken";
    debugPrint("Provider token updated: $newToken");

    notifyListeners();
  }

  void setAuthToken(String token) {
    dio.options.headers["Authorization"] = "JWT $token";
    debugPrint("Provider token updated to $token");
  }

  /// User State Management
  Future<void> refreshUserState() async {
    print(">>> [refreshUserState] Refreshing user state...");
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final accessToken = prefs.getString('access_token');

      if (userId == null || accessToken == null) {
        throw Exception("Missing user ID or access token.");
      }

      dio.options.headers["Authorization"] = "JWT $accessToken";
      final response =
          await dio.get("https://racheeta.pythonanywhere.com/users/$userId/");

      if (response.statusCode == 200) {
        final userData = response.data;

        await prefs.setString('user_id', userData["user_id"]);
        await prefs.setString("full_name", userData["full_name"]);
        await prefs.setString("email", userData["email"]);
        await prefs.setString(
            "gps_location", userData["gps_location"] ?? "N/A");
        await prefs.setString('phone_number', userData["phone_number"]);
        await prefs.setString('gender', userData["gender"]);

        debugPrint("User state refreshed: $userData");
        notifyListeners();
      } else {
        debugPrint("Failed to refresh user state: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error in refreshUserState: $e");
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
      debugPrint("Error in NurseRetroDisplayGetProvider.fetchMe(): $e");
      rethrow;
    }
  }

  Future<void> updateAdvertisement({
    required String nurseId,
    required bool advertise,
    required String advertisePrice,
    required String advertiseDuration,
  }) async {
    print('>>> [Update Advertisement] Starting function');
    print('>>> [Update Advertisement] Nurse ID: $nurseId');

    final requestBody = {
      "advertise": advertise,
      "advertise_price": advertisePrice,
      "advertise_duration": advertiseDuration,
    };

    print('>>> [Update Advertisement] Request Payload: $requestBody');

    try {
      // Call the nurse-specific update method
      final updatedNurse = await _apiClient.updateNurse(nurseId, requestBody);
      print(
          '>>> [Update Advertisement] Server Response: ${updatedNurse.toJson()}');

      // Update the local list (assuming you have a list called _nurses)
      final index = _nurses.indexWhere((nurse) => nurse.id == nurseId);
      if (index != -1) {
        _nurses[index] = updatedNurse;
        notifyListeners();
      } else {
        print('>>> [Update Advertisement] Nurse ID not found in local list.');
      }
    } catch (e) {
      print('>>> [Update Advertisement] Error occurred: $e');
      if (e is DioError) {
        print('>>> [Update Advertisement] DioError Details:');
        print('    Request URL: ${e.requestOptions.uri}');
        print('    Request Headers: ${e.requestOptions.headers}');
        print('    Request Data: ${e.requestOptions.data}');
        print('    Response Data: ${e.response?.data}');
        print('    Status Code: ${e.response?.statusCode}');
      }
    }
  }

  /// Check if a nurse has an active advertisement
  Future<Map<String, dynamic>?> getActiveAd(String nurseId) async {
    try {
      final NurseModel nurse = await _apiClient.getNurseById(nurseId);

      debugPrint(">>> [getActiveAd] Nurse fetched: ${nurse.toJson()}");

      if (nurse.advertise == true) {
        final DateTime startDate = DateTime.parse(
            nurse.createDate ?? DateTime.now().toIso8601String());
        final DateTime endDate = DateTime.parse(
            nurse.updateDate ?? DateTime.now().toIso8601String());

        debugPrint(">>> [getActiveAd] Active advertisement found with dates.");

        return {
          'duration': nurse.advertiseDuration ?? 'N/A',
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
