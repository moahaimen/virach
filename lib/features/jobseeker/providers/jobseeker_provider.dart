import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../doctors/models/user_model.dart'; // If you need user creation
import '../models/jobseeker_model.dart';
import '../services/api_client.dart'; // The newly created API client

class JobSeekerRetroDisplayGetProvider with ChangeNotifier {
  late ApiClient _apiClient;
  final List<JobSeekerModel> _jobSeekers = [];
  JobSeekerModel? _selectedJobSeeker; // If you want to store a single jobseeker
  Dio dio = Dio();
  // Public getters
  List<JobSeekerModel> get jobSeekers => _jobSeekers;
  JobSeekerModel? get selectedJobSeeker => _selectedJobSeeker;

  /// Constructor:
  /// Pass in the JWT token so we can set the header
  JobSeekerRetroDisplayGetProvider(String token) {
    Dio dio = Dio();
    dio.options.headers["Authorization"] = "JWT $token";
    _apiClient = ApiClient(dio);
  }

  // ---------------------------
  // 1) CREATE JobSeeker
  // ---------------------------
// ────────────────────────────────────────────────────────────
// JobSeekerRetroDisplayGetProvider.dart
// Replace the entire createJobSeeker method with this version
// ────────────────────────────────────────────────────────────
  Future<JobSeekerModel?> createJobSeeker({
    required String userId,
    required String specialty,
    required String degree,
    required String address,
    required String gpsLocation,
  }) async {
    try {
      // DRF expects `user` to be a nested object, not a string.
      final Map<String, dynamic> payload = {
        "user": {"id": userId},
        "specialty": specialty,
        "degree": degree,
        "address": address,
        "gps_location": gpsLocation,
      };

      debugPrint("🔹 Sending Payload to Server: $payload");
      final JobSeekerModel response = await _apiClient.createJobSeeker(payload);
      debugPrint("✅ Server Response: ${response.toJson()}");

      // keep local state in‑sync
      _jobSeekers.add(response);
      notifyListeners();
      return response;
    } on DioException catch (e) {
      debugPrint("❌ DioException");
      debugPrint("   • type       : ${e.type}");
      debugPrint("   • statusCode : ${e.response?.statusCode}");
      debugPrint("   • data       : ${e.response?.data}");
      return null;
    } catch (e) {
      debugPrint("❌ Unexpected error in createJobSeeker ⇒ $e");
      return null;
    }
  }

  // Future<JobSeekerModel?> createJobSeeker({
  //   required String userId,
  //   required String specialty,
  //   required String degree,
  //   String? degreeImage,
  //   String? address,
  //   String? gpsLocation,
  //   // required bool wantsProfessionalCourses,
  //   File? degreeImageFile,
  // }) async {
  //   try {
  //     // Build request payload
  //     final requestBody = {
  //       "user": userId,
  //       "specialty": specialty,
  //       "degree": degree,
  //       "degree_image": degreeImage,
  //       "address": address,
  //       "gps_location": gpsLocation,
  //       // "wants_professional_courses": wantsProfessionalCourses,
  //       "degree_image_file":
  //           degreeImageFile != null ? "File is attached" : null,
  //     };
  //
  //     debugPrint("🔹 Sending Payload to Server: $requestBody");
  //
  //     final response = await _apiClient.createJobSeeker(requestBody);
  //
  //     debugPrint("✅ Server Response: ${response.toJson()}");
  //
  //     // Add response to local list and notify listeners
  //     _jobSeekers.add(response);
  //     notifyListeners();
  //
  //     return response;
  //   } catch (e) {
  //     debugPrint("❌ Error saving profile: $e");
  //
  //     if (e is DioException) {
  //       debugPrint("🔻 Dio Error Type: ${e.type}");
  //       debugPrint("🔻 Response Data: ${e.response?.data}");
  //       debugPrint("🔻 Status Code: ${e.response?.statusCode}");
  //       debugPrint("🔻 Request Data Sent: ${e.requestOptions.data}");
  //
  //       if (e.response?.data is Map<String, dynamic>) {
  //         e.response?.data.forEach((key, value) {
  //           debugPrint("⚠️ Field causing issue: $key -> $value");
  //         });
  //       }
  //     }
  //     return null;
  //   }
  // }

  // ---------------------------
  // 2) FETCH ALL JobSeekers
  // ---------------------------
  Future<void> fetchJobSeekers() async {
    try {
      final result = await _apiClient.fetchJobSeekers();
      _jobSeekers.clear();
      _jobSeekers.addAll(result);
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching JobSeekers: $e");
    }
  }

  // ---------------------------
  // 3) FETCH single JobSeeker by ID
  // ---------------------------
  Future<JobSeekerModel?> fetchJobSeekerById(String jobSeekerId) async {
    try {
      final result = await _apiClient.fetchJobSeekerById(jobSeekerId);
      _selectedJobSeeker = result;
      notifyListeners();
      return result;
    } catch (e) {
      debugPrint("Error fetching JobSeeker by ID: $e");
      return null;
    }
  }

  Future<JobSeekerModel?> fetchCurrentJobSeeker() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) {
        throw Exception("User ID not found in SharedPreferences");
      }

      final jobSeeker = await _apiClient.fetchJobSeekerById(userId);
      debugPrint("User data fetched successfully: ${jobSeeker.toJson()}");
      return jobSeeker;
    } catch (e) {
      debugPrint("Error fetching user details: $e");
      return null;
    }
  }

  Future<void> updateCurrentUser(Map<String, dynamic> updatedData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId == null) {
        print("❌ Error: User ID not found in SharedPreferences");
        throw Exception("User ID not found in SharedPreferences");
      }

      // 🔹 Print the API endpoint
      final apiUrl = "https://racheeta.pythonanywhere.com/users/$userId/";
      print("🚀 Sending PATCH request to: $apiUrl");

      // 🔹 Print the request payload
      print("📦 Payload being sent: $updatedData");

      // Send PATCH request
      final UserModel response =
          await _apiClient.updateUser(userId, updatedData);

      // 🔹 Print the full response (UserModel fields)
      print("✅ Server Response (UserModel):");
      print("   - ID: ${response.id}");
      print("   - Full Name: ${response.fullName}");
      print("   - Email: ${response.email}");
      print("   - Phone: ${response.phoneNumber}");
      print("   - Gender: ${response.gender}");
      print("   - Profile Image: ${response.profileImage}");
      print("   - GPS Location: ${response.gpsLocation}");

      print("✅ User profile updated successfully.");
    } on DioError catch (e) {
      print("❌ DioError occurred: Status Code ${e.response?.statusCode}");

      if (e.response != null) {
        // 🔹 Print Response Data
        print("📝 Response Data: ${e.response?.data}");

        // 🔹 Extract error fields
        if (e.response?.data is Map<String, dynamic>) {
          final errorData = e.response?.data as Map<String, dynamic>;
          errorData.forEach((field, errorMessages) {
            print("🔍 Field '$field' Error: $errorMessages");
          });

          // Show the first error field in logs
          String firstErrorField = errorData.keys.first;
          String firstErrorMessage = errorData[firstErrorField].toString();
          print(
              "⚠️ First Error: Field '$firstErrorField' - $firstErrorMessage");
        }
      }
    } catch (e) {
      print("❌ Unexpected error updating user profile: $e");
    }
  }

  Future<UserModel?> fetchUserById(String userId) async {
    try {
      final response = await _apiClient.getUserById(userId);
      return response;
    } catch (e) {
      debugPrint("Error fetching user details: $e");
      return null;
    }
  }

  // ---------------------------
  // 4) FETCH JobSeekers by specialty
  // ---------------------------
  Future<List<JobSeekerModel>> fetchJobSeekersBySpecialty(
      String specialty) async {
    try {
      final result = await _apiClient.fetchJobSeekersBySpecialty(specialty);
      // You might want to store them separately or replace the current list
      _jobSeekers.clear();
      _jobSeekers.addAll(result);
      notifyListeners();
      return result;
    } catch (e) {
      debugPrint("Error fetching JobSeekers by specialty: $e");
      return [];
    }
  }

  // ---------------------------
  // 5) UPDATE a JobSeeker
  // ---------------------------
  Future<JobSeekerModel?> updateJobSeeker({
    required String jobSeekerId,
    String? specialty,
    String? degree,
    String? address,
    bool? isArchived,
  }) async {
    try {
      // Build the partial update map:
      final requestBody = <String, dynamic>{};
      if (specialty != null) requestBody['specialty'] = specialty;
      if (degree != null) requestBody['degree'] = degree;
      if (address != null) requestBody['address'] = address;
      if (isArchived != null) requestBody['is_archived'] = isArchived;

      final updated =
          await _apiClient.updateJobSeeker(jobSeekerId, requestBody);

      // Update local list
      final index = _jobSeekers.indexWhere((js) => js.id == jobSeekerId);
      if (index != -1) {
        _jobSeekers[index] = updated;
      }
      // If you're tracking the selectedJobSeeker
      if (_selectedJobSeeker != null && _selectedJobSeeker!.id == jobSeekerId) {
        _selectedJobSeeker = updated;
      }

      notifyListeners();
      return updated;
    } catch (e) {
      debugPrint("Error updating JobSeeker: $e");
      return null;
    }
  }

  // ---------------------------
  // 6) DELETE a JobSeeker
  // ---------------------------
  Future<bool> deleteJobSeeker(String jobSeekerId) async {
    try {
      await _apiClient.deleteJobSeeker(jobSeekerId);
      // Remove from local list
      _jobSeekers.removeWhere((js) => js.id == jobSeekerId);
      if (_selectedJobSeeker != null && _selectedJobSeeker!.id == jobSeekerId) {
        _selectedJobSeeker = null;
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error deleting JobSeeker: $e");
      return false;
    }
  }

  // ---------------------------
  //  BONUS: CREATE user before jobseeker
  // ---------------------------
  Future<UserModel?> createUser({
    required String email,
    required String fullName,
    required String password,
    required String role,
    required String phoneNumber,
  }) async {
    try {
      // Basic user data
      final userMap = {
        "email": email,
        "full_name": fullName,
        "password": password,
        "role": role,
        "phone_number": phoneNumber,
      };

      final user = await _apiClient.createUser(userMap);
      return user;
    } catch (e) {
      debugPrint("Error creating User: $e");
      return null;
    }
  }
  // Inside JobSeekerRetroDisplayGetProvider class:

  /// CREATE user in backend (like "createUser" but returning a Map).
  /// This matches your UI's call: provider.saveUserProfile(...)
  Future<Map<String, dynamic>> saveUserProfile(
      Map<String, dynamic> userData) async {
    try {
      // 1) Use _apiClient to create user
      final userModel = await _apiClient.createUser(userData);

      // 2) Convert userModel to JSON map
      final Map<String, dynamic> responseMap = userModel.toJson();

      // 3) Return the map to the UI
      return responseMap;
    } catch (e) {
      rethrow;
    }
  }

  // Inside JobSeekerRetroDisplayGetProvider:

  /// AUTHENTICATE user with email/password
  /// returns the JWT access token or null on error
  Future<String?> authenticateUser(String email, String password) async {
    try {
      final response = await dio.post(
        "https://racheeta.pythonanywhere.com/login/",
        data: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        final accessToken = response.data["access"];
        // you might also have refresh = response.data["refresh"];
        return accessToken;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
  // Inside JobSeekerRetroDisplayGetProvider:

  void setAuthToken(String token) {
    dio.options.headers["Authorization"] = "JWT $token";
    debugPrint("Provider token updated to $token");
  }

  // Inside JobSeekerRetroDisplayGetProvider class
  Future<JobSeekerModel?> fetchCurrentJobSeekerByUserID() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) {
        throw Exception("User ID not found in SharedPreferences");
      }
      // Use the filter endpoint
      final results = await _apiClient.fetchJobSeekerByUserId(userId);
      if (results.isNotEmpty) {
        return results.first; // Expecting a single jobseeker per user.
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching JobSeeker by user ID: $e");
      return null;
    }
  }
}
