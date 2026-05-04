import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../doctors/models/user_model.dart';
import '../services/api_client.dart';
import '../models/hospitals_model.dart';

class HospitalRetroDisplayGetProvider with ChangeNotifier {
  late ApiClient _apiClient;
  List<HospitalModel> _hospitals = []; // List to store fetched hospitals
  Dio dio = Dio();
  // Add these two lines to make /me/ available
  Map<String, dynamic>? _meData;
  Map<String, dynamic>? get meData => _meData;

  ///constructor
  HospitalRetroDisplayGetProvider(String token) {
    dio.options.headers["Authorization"] = "JWT $token";
    _apiClient = ApiClient(dio);
  }

  List<HospitalModel> get hospitals => _hospitals;

  /// Fetch Hospitals
  Future<void> fetchHospitals() async {
    print("Fetching hospitals...");
    try {
      final response = await _apiClient.fetchHospitals();
      _hospitals = response;
      print("Fetched Hospitals: $_hospitals");
      notifyListeners();
    } catch (e) {
      print("Error fetching hospitals: $e");
    }
  }

  /// Create Hospital
  Future<HospitalModel?> createHospital({
    required UserModel userModel,
    required String hospitalName,
    required String bio,
    required String availabilityTime,
    //required bool advertise,
    String? address,
    String? gpsLocation,
    String? profileImage,
    String? specialty,
    String? administration,
    String? phoneNumber,
    // double? advertisePrice,
    // String? advertiseDuration,
  }) async {
    print(">>> [createHospital] Starting hospital creation...");

    if (userModel.id == null || userModel.id!.isEmpty) {
      throw ArgumentError('Cannot create hospital without a created user id');
    }

    final Map<String, dynamic> payload = {
      "user": {"id": userModel.id},
      "hospital_name": hospitalName,
      "specialty": specialty,
      "administration": administration,
      "bio": bio,
      "address": address,
      "availability_time": availabilityTime,
      "gps_location": gpsLocation,
      // "advertise": advertise,
      // "advertise_price": advertisePrice?.toString(),
      // "advertise_duration": advertiseDuration,
      "profile_image": profileImage,
      "phone_number": phoneNumber,
    };

    // ✅ Remove null values before sending the request
    payload.removeWhere((key, value) => value == null);

    print(">>> [createHospital] Payload: $payload");

    try {
      final HospitalModel response = await _apiClient.createHospital(payload);
      print(
          ">>> [createHospital] Hospital created successfully: ${response.toJson()}");
      _hospitals.add(response);
      notifyListeners();
      return response;
    } catch (e) {
      if (e is DioError) {
        print(">>> [DEBUG] DioError occurred during createHospital:");
        print(
            ">>> [DEBUG] Error Response Status Code: ${e.response?.statusCode}");
        print(">>> [DEBUG] Error Response Headers: ${e.response?.headers}");
        print(">>> [DEBUG] Error Response Data: ${e.response?.data}");
      } else {
        print(">>> [DEBUG] Unexpected error during createHospital: $e");
      }
      rethrow;
    }
  }

  /// Update Hospital
  Future<HospitalModel?> updateHospital({
    required String id,
    String? hospitalName,
    String? bio,
    String? availabilityTime,
    bool? advertise,
    String? address,
    String? gpsLocation,
    String? profileImage,
    String? specialty,
    String? administration,
    String? phoneNumber,
    String? advertisePrice,
    String? advertiseDuration,
  }) async {
    print("Updating hospital with ID: $id");
    try {
      final hospitalData = {
        "hospital_name": hospitalName,
        "bio": bio,
        "availability_time": availabilityTime,
        "advertise": advertise,
        "address": address,
        "gps_location": gpsLocation,
        "profile_image": profileImage,
        "specialty": specialty,
        "administration": administration,
        "phone_number": phoneNumber,
        "advertise_price": advertisePrice,
        "advertise_duration": advertiseDuration,
      };
      hospitalData.removeWhere((key, value) => value == null);

      final response = await _apiClient.updateHospital(id, hospitalData);
      final index = _hospitals.indexWhere((hospital) => hospital.id == id);
      if (index != -1) {
        _hospitals[index] = response;
        notifyListeners();
      }
      print("Updated Hospital: $response");
      return response;
    } catch (e) {
      print("Error updating hospital: $e");
      return null;
    }
  }

  /// Delete Hospital
  Future<void> deleteHospital(String id) async {
    print("Deleting hospital with ID: $id");
    try {
      await _apiClient.deleteHospital(id);
      _hospitals.removeWhere((hospital) => hospital.id == id);
      print("Deleted hospital with ID: $id");
      notifyListeners();
    } catch (e) {
      print("Error deleting hospital: $e");
    }
  }

  Future<void> updateToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", newToken);

    dio.options.headers["Authorization"] = "JWT $newToken";
    debugPrint("Provider token updated: $newToken");

    // Notify listeners to ensure UI updates if necessary
    notifyListeners();
  }

  Future<void> updateAdvertisement({
    required String hospitalId,
    required bool advertise,
    required String advertisePrice,
    required String advertiseDuration,
  }) async {
    // Ensure hospitalId is not empty
    if (hospitalId.isEmpty) {
      print(
          '>>> [Update Advertisement] ❌ Error: Hospital ID is EMPTY! Aborting request.');
      return;
    }

    print('>>> [Update Advertisement] 🏥 Hospital ID: $hospitalId');

    final requestBody = {
      "advertise": advertise,
      "advertise_price": advertisePrice,
      "advertise_duration": advertiseDuration,
    };

    print(
        '>>> [Update Advertisement] 📡 Sending Request Payload: $requestBody');

    try {
      // Ensure the PATCH request includes the correct hospitalId
      final url = 'https://racheeta.pythonanywhere.com/hospitals/$hospitalId/';

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

  Future<Map<String, dynamic>?> getActiveAd(String hospitalId) async {
    try {
      final hospital = await _apiClient.getHospitalById(hospitalId);
      debugPrint('>>> [getActiveAd] fetched: ${hospital.toJson()}');

      final advertiseFlag = hospital.advertise ?? false;
      final durStr        = hospital.advertiseDuration;

      if (advertiseFlag && durStr != null && hospital.createDate != null) {
        final start = DateTime.parse(hospital.createDate!);
        final months = int.tryParse(durStr) ?? 0;
        final end   = DateTime(start.year, start.month + months, start.day);

        return {
          'duration'  : durStr,
          'start_date': start,
          'end_date'  : end,
        };
      }

      debugPrint('>>> [getActiveAd] no active ad');
      return null;
    } catch (e) {
      debugPrint('>>> [getActiveAd] error: $e');
      return null;
    }
  }


  /// Check if a nurse has an active advertisement
  // Future<Map<String, dynamic>?> getActiveAd(String hospitalId) async {
  //   try {
  //     final response =
  //         await _apiClient.getHospitalById(hospitalId); // Fetch nurse
  //     final hospital = HospitalModel.fromJson(response.toJson());
  //
  //     if (hospital.advertise == true) {
  //       // Check if nurse has an active advertisement
  //       return {
  //         'duration': hospital.advertiseDuration,
  //         'start_date': hospital.createDate,
  //         'end_date':
  //             hospital.updateDate, // Adjust according to your backend logic
  //       };
  //     }
  //
  //     return null; // No active advertisement
  //   } catch (e) {
  //     print("Error fetching active ad for nurse: $e");
  //     return null;
  //   }
  // }

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
      debugPrint("Error in HospitalRetroDisplayGetProvider.fetchMe(): $e");
      rethrow;
    }
  }
}
