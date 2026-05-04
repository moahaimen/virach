import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../doctors/models/user_model.dart';
import '../services/api_client.dart';
import '../models/labs_model.dart';

class LabsRetroDisplayGetProvider with ChangeNotifier {
  late ApiClient _apiClient;
  List<LabsModel> _labs = []; // List to store fetched laboratories

  // This Dio is also used to fetch /me/ data and do all requests
  Dio dio = Dio();

  // We store /me/ data here so the UI can read it
  Map<String, dynamic>? _meData;
  Map<String, dynamic>? get meData => _meData;

  LabsRetroDisplayGetProvider(String token) {
    dio.options.headers["Authorization"] = "JWT $token";
    _apiClient = ApiClient(dio);
  }

  /// Optional method to manually set meData after a fetch
  void setLabMeData(Map<String, dynamic> data) {
    _meData = data;
    notifyListeners();
  }

  List<LabsModel> get labs => _labs;

  Future<LabsModel?> createLaboratory({
    required UserModel userModel,
    required String laboratoryName,
    required String availableTests,
    required String bio,
    required String availabilityTime,
    required String phoneNumber,
    String? address,
    String? gpsLocation,
    String? profileImage,
  }) async {
    print(">>> [createLaboratory] Starting lab creation...");

    if (userModel.id == null || userModel.id!.isEmpty) {
      throw ArgumentError('Cannot create laboratory without a created user id');
    }

    final laboratoryData = {
      "user": {"id": userModel.id},
      "laboratory_name": laboratoryName,
      "available_tests": availableTests,
      "bio": bio,
      "availability_time": availabilityTime,
      "phone_number": phoneNumber,
      "address": address,
      "profile_image": profileImage,
    };

    // Remove null entries
    laboratoryData.removeWhere((key, value) => value == null);

    print(">>> [DEBUG] Payload for createLaboratory: $laboratoryData");

    try {
      print(">>> [DEBUG] Sending request to create laboratory...");
      final response = await _apiClient.createLaboratory(laboratoryData);
      print(">>> [DEBUG] Server response received: ${response.toJson()}");

      final createdLab = response;
      _labs.add(createdLab);
      notifyListeners();
      print(
          ">>> [DEBUG] Laboratory created successfully: ${createdLab.toJson()}");

      return createdLab;
    } on DioError catch (e) {
      print(
          ">>> [ERROR] DioError occurred while creating laboratory: ${e.message}");
      if (e.response != null) {
        print(">>> [DEBUG] Status Code: ${e.response?.statusCode}");
        print(">>> [DEBUG] Response Data: ${e.response?.data}");
      }
      return null;
    } catch (e) {
      print(">>> [ERROR] Unexpected error creating laboratory: $e");
      return null;
    }
  }

  /// Fetch all labs (if you have an endpoint for that)
  Future<List<LabsModel>> fetchLaboratories() async {
    try {
      final response = await _apiClient.fetchLaboratories();
      _labs = response;
      notifyListeners();
      return response;
    } catch (e) {
      print("Error fetching laboratories: $e");
      return [];
    }
  }

  /// Update a specific lab
  Future<LabsModel?> updateLaboratory({
    required String id,
    bool? isArchived,
    String? laboratoryName,
    String? availableTests,
    String? bio,
    String? availabilityTime,
    bool? advertise,
    String? phoneNumber,
    String? address,
    String? gpsLocation,
    double? advertisePrice,
    String? advertiseDuration,
    String? profileImage,
  }) async {
    try {
      final laboratoryData = {
        "is_archived": isArchived,
        "laboratory_name": laboratoryName,
        "available_tests": availableTests,
        "bio": bio,
        "availability_time": availabilityTime,
        "advertise": advertise,
        "phone_number": phoneNumber,
        "address": address,
        "gps_location": gpsLocation,
        "advertise_price": advertisePrice,
        "advertise_duration": advertiseDuration,
        "profile_image": profileImage,
      };
      laboratoryData.removeWhere((key, value) => value == null);

      final response = await _apiClient.updateLaboratory(id, laboratoryData);
      final index = _labs.indexWhere((lab) => lab.id == id);
      if (index != -1) {
        _labs[index] = response;
        notifyListeners();
      }
      return response;
    } catch (e) {
      print("Error updating laboratory: $e");
      return null;
    }
  }

  Future<void> deleteLaboratory(String id) async {
    try {
      await _apiClient.deleteLaboratory(id);
      _labs.removeWhere((lab) => lab.id == id);
      notifyListeners();
    } catch (e) {
      print("Error deleting laboratory: $e");
    }
  }

  Future<void> updateToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", newToken);

    dio.options.headers["Authorization"] = "JWT $newToken";
    debugPrint("Provider token updated: $newToken");
    notifyListeners();
  }

  /// Simplified ad update
  Future<void> updateAdvertisement({
    required String laboratoryId,
    required bool advertise,
    required String advertisePrice,
    required String advertiseDuration,
  }) async {
    print('>>> [Update Advertisement] Starting function');

    if (laboratoryId.isEmpty) {
      print("🚨 ERROR: laboratoryId is EMPTY. Cannot send PATCH request.");
      return;
    }

    print("✅ [Update Advertisement] Using Laboratory ID: $laboratoryId");
    final Map<String, dynamic> requestBody = {
      "advertise": advertise,
      "advertise_price": advertisePrice,
      "advertise_duration": advertiseDuration,
    };
    print('>>> [Update Advertisement] Request Payload: $requestBody');

    try {
      final updatedLab =
          await _apiClient.updateLaboratory(laboratoryId, requestBody);
      print(
          '>>> [Update Advertisement] ✅ Server Response: ${updatedLab.toJson()}');

      // Update local list
      final index = _labs.indexWhere((lab) => lab.id == laboratoryId);
      if (index != -1) {
        _labs[index] = updatedLab;
        notifyListeners();
        print("✅ [Update Advertisement] Local list updated successfully.");
      } else {
        print("⚠️ [Update Advertisement] Lab ID NOT found in local list.");
      }
    } catch (e) {
      print('>>> [Update Advertisement] ❌ ERROR occurred: $e');
      if (e is DioError) {
        print(
            '>>> [Update Advertisement] ❌ DioError Details: ${e.response?.data}');
      }
    }
  }

  /// Check if a lab has an active advertisement
  Future<Map<String, dynamic>?> getActiveAd(String laboratoryId) async {
    try {
      final LabsModel lab = await _apiClient.getLaboratoryById(laboratoryId);
      debugPrint(">>> [getActiveAd] Laboratory fetched: ${lab.toJson()}");

      if (lab.advertise == true) {
        final DateTime startDate =
            DateTime.parse(lab.createDate ?? DateTime.now().toIso8601String());
        final DateTime endDate =
            DateTime.parse(lab.updateDate ?? DateTime.now().toIso8601String());

        debugPrint(">>> [getActiveAd] Active advertisement found with dates.");
        return {
          'duration': lab.advertiseDuration ?? 'N/A',
          'start_date': startDate,
          'end_date': endDate,
        };
      }

      debugPrint(">>> [getActiveAd] No active advertisement for Laboratory.");
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
      debugPrint("Error in LabrotaryRetroDisplayGetProvider.fetchMe(): $e");
      rethrow;
    }
  }
}
