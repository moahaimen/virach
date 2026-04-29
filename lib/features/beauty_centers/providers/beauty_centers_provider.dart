import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../doctors/models/user_model.dart';
import '../services/api_client.dart';
import '../models/beauty_centers_model.dart';

class BeautyCentersRetroDisplayGetProvider with ChangeNotifier {
  late ApiClient _apiClient;
  List<BeautyCentersModel> _beautyCenters =
      []; // List to store fetched beauty centers
  Dio dio = Dio();
  Map<String, dynamic>? _meData;
  Map<String, dynamic>? get meData => _meData;
  BeautyCentersRetroDisplayGetProvider(String token) {
    dio.options.headers["Authorization"] = "JWT $token";
    _apiClient = ApiClient(dio);
  }

  List<BeautyCentersModel> get beautyCenters => _beautyCenters;

  Future<BeautyCentersModel?> createBeautyCenters({
    required UserModel userModel,
    required String centerName,
    required String bio,
    required String availabilityTime,
    bool? advertise,
    required String phoneNumber,
    bool? isArchived,
    String? address,
    String? gpsLocation,
    double? advertisePrice,
    String? advertiseDuration,
    String? profileImage,
  }) async {
    print(">>> [DEBUG] Starting createBeautyCenters...");
    try {
      // Prepare the user payload
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
      };

      print(">>> [DEBUG] User payload prepared:");
      print(userPayload);

      // Prepare the beauty center payload
      final Map<String, dynamic> beautyCenterData = {
        "user": userPayload,
        "center_name": centerName,
        "bio": bio,
        "availability_time": availabilityTime,
        "advertise": advertise,
        "address": address,
        "gps_location": gpsLocation,
        "phone_number": phoneNumber,
        "advertise_price": advertisePrice,
        "advertise_duration": advertiseDuration,
        "profile_image": profileImage,
      };
      beautyCenterData.removeWhere((key, value) => value == null);

      print(">>> [DEBUG] Beauty center payload prepared:");
      print(beautyCenterData);

      // Send the request
      print(">>> [DEBUG] Sending request to create beauty center...");
      final response = await _apiClient.createBeautyCenters(beautyCenterData);

      print(">>> [DEBUG] Server response received:");
      print(response.toJson()); // Assuming response is a parsed model

      // Add the new beauty center to the list
      _beautyCenters.add(response);
      notifyListeners();

      return response;
    } on DioError catch (e) {
      // Handle Dio-specific errors
      print(">>> [ERROR] DioError occurred while creating beauty center:");
      print("Error Type: ${e.type}");
      print("Error Message: ${e.message}");

      if (e.response != null) {
        print(">>> [DEBUG] DioError Response:");
        print("Status Code: ${e.response?.statusCode}");
        print("Response Data: ${e.response?.data}");

        if (e.response?.data is Map<String, dynamic>) {
          e.response?.data.forEach((field, message) {
            print(">>> [DEBUG] Field Error: $field - $message");
          });
        }
      } else {
        print(">>> [DEBUG] No response received from server.");
      }
      return null;
    } catch (e, stackTrace) {
      // Handle unexpected errors
      print(">>> [ERROR] Unexpected error while creating beauty center:");
      print("Error: $e");
      print("Stack Trace: $stackTrace");
      return null;
    }
  }

  Future<List<BeautyCentersModel>> fetchBeautyCenters() async {
    try {
      final response = await _apiClient.fetchBeautyCenters();
      _beautyCenters = response;
      notifyListeners();
      return response;
    } catch (e) {
      print("Error fetching beauty centers: $e");
      return [];
    }
  }

  Future<BeautyCentersModel?> updateBeautyCenters({
    required String id,
    String? centerName,
    String? bio,
    String? availabilityTime,
    bool? advertise,
    String? phoneNumber,
    bool? isArchived,
    String? address,
    String? gpsLocation,
    double? advertisePrice,
    String? advertiseDuration,
    String? profileImage,
  }) async {
    try {
      final beautyCenterData = {
        "center_name": centerName,
        "bio": bio,
        "availability_time": availabilityTime,
        "advertise": advertise,
        "phone_number": phoneNumber,
        "is_archived": isArchived,
        "address": address,
        "gps_location": gpsLocation,
        "advertise_price": advertisePrice,
        "advertise_duration": advertiseDuration,
        "profile_image": profileImage,
      };
      beautyCenterData.removeWhere((key, value) => value == null);

      final response =
          await _apiClient.updateBeautyCenters(id, beautyCenterData);
      final index = _beautyCenters.indexWhere((center) => center.id == id);
      if (index != -1) {
        _beautyCenters[index] = response;
        notifyListeners();
      }
      return response;
    } catch (e) {
      print("Error updating beauty center: $e");
      return null;
    }
  }

  Future<void> deleteBeautyCenters(String id) async {
    try {
      await _apiClient.deleteBeautyCenters(id);
      _beautyCenters.removeWhere((center) => center.id == id);
      notifyListeners();
    } catch (e) {
      print("Error deleting beauty center: $e");
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
    required String beautyCenterId,
    required bool advertise,
    required String advertisePrice,
    required String advertiseDuration,
  }) async {
    print('>>> [Update Advertisement] Starting function');

    // Ensure we have a valid ID
    if (beautyCenterId.isEmpty) {
      print("🚨 ERROR: BeautyCenter ID is empty. Cannot send PATCH request.");
      return;
    }

    print('>>> [Update Advertisement] 🏥 Beauty Center ID: $beautyCenterId');

    // Retrieve the JWT token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("Login_access_token");

    if (token == null || token.isEmpty) {
      print("🚨 [Update Advertisement] ERROR: No authentication token found!");
      return;
    }

    print("✅ [Update Advertisement] Using JWT Token: $token");

    final requestBody = {
      "advertise": advertise,
      "advertise_price": advertisePrice,
      "advertise_duration": advertiseDuration,
    };

    print(
        '>>> [Update Advertisement] 📡 Sending Request Payload: $requestBody');

    try {
      // Ensure the PATCH request includes the correct Beauty Center ID
      final url =
          'https://racheeta.pythonanywhere.com/beauty-centers/$beautyCenterId/';

      final response = await dio.patch(
        url,
        data: requestBody,
        options: Options(headers: {
          "Authorization": "JWT $token", // ✅ Ensure the JWT token is added here
          "Content-Type": "application/json",
        }),
      );

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
  Future<Map<String, dynamic>?> getActiveAd(String beautyCenterId) async {
    try {
      final response =
          await _apiClient.getHospitalById(beautyCenterId); // Fetch nurse
      final beautyCenter = BeautyCentersModel.fromJson(response.toJson());

      if (beautyCenter.advertise == true) {
        // Check if nurse has an active advertisement
        return {
          'duration': beautyCenter.advertiseDuration,
          'start_date': beautyCenter.createDate,
          'end_date':
              beautyCenter.updateDate, // Adjust according to your backend logic
        };
      }

      return null; // No active advertisement
    } catch (e) {
      print("Error fetching active ad for beautyCenter: $e");
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
        throw Exception("Failed to fetch /me/ data");
      }
    } catch (e) {
      debugPrint("Error in PharmaRetroDisplayGetProvider.fetchMe(): $e");
      rethrow;
    }
  }
}
