import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_client.dart';
import '../../../doctors/models/user_model.dart';

class PatientRetroDisplayGetProvider with ChangeNotifier {
  late ApiClient _apiClient;

  List<UserModel> _users = []; // Store fetched users
  List<UserModel> get users => _users; // Expose users to the UI
  Dio dio = Dio();

  PatientRetroDisplayGetProvider(String token) {
    // Initialize Dio and set the Authorization header
    Dio dio = Dio();

    dio.options.headers["Authorization"] = "JWT $token";
    _apiClient = ApiClient(dio); // Initialize the API client
  }

  // Fetch all users from the backend
  Future<void> fetchAllUsers() async {
    try {
      final fetchedUsers = await _apiClient.getAllUsers();
      _users = fetchedUsers;
      notifyListeners(); // Notify listeners of the state change
    } catch (e) {
      debugPrint("Error fetching users: $e");
    }
  }

  // Future<void> _sendFirebaseAuth(
  //     String email, String firebaseUid, String password) async {
  //   try {
  //     final dio = Dio();
  //     final response = await dio.post(
  //       "https://racheeta.pythonanywhere.com/firebase-auth/",
  //       data: {
  //         "email": email,
  //         "firebase_uid": firebaseUid,
  //         "password": password,
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       debugPrint("Firebase Auth data sent successfully: ${response.data}");
  //     } else {
  //       debugPrint("Failed to send Firebase Auth data: ${response.data}");
  //     }
  //   } catch (e) {
  //     debugPrint("Error sending Firebase Auth data: $e");
  //   }
  // }
  // Future<void> authenticateUser(String email, String password) async {
  //   try {
  //     final dio = Dio();
  //     final response = await dio.post(
  //       "https://racheeta.pythonanywhere.com/login/",
  //       data: {"email": email, "password": password},
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final accessToken = response.data["access"];
  //       final refreshToken = response.data["refresh"];
  //
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString("access_token", accessToken);
  //       await prefs.setString("refresh_token", refreshToken);
  //       await prefs.setBool('isRegistered', true);
  //
  //       debugPrint("Access token saved: $accessToken");
  //     } else {
  //       throw Exception("Failed to authenticate user");
  //     }
  //   } catch (e) {
  //     debugPrint("Error authenticating user: $e");
  //     rethrow; // Throw the error back to handle it higher up
  //   }
  // }

  void setAuthToken(String token) {
    dio.options.headers["Authorization"] =
        "JWT eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzQ5OTQwMTkzLCJpYXQiOjE3NDIxNjQxOTMsImp0aSI6IjZmOTAyYjVlOTc3ZjRlZjc5ZDA0ODQ4MDY0NzRhODZlIiwidXNlcl9pZCI6IjQzNGI4M2Y3LTFhYjItNGRkMy1iOTQzLTBhZjJiZTU1NmE5NCJ9.gOhDW3ab-7_-D5kOXYbpIB61qByPi2sesUONiGXUFcA";
    debugPrint("Provider token updated to $token");
  }

  // Future<void> refreshUserState() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final userId = prefs.getString('user_id');
  //   final accessToken = prefs.getString('access_token');
  //
  //   if (userId != null && accessToken != null) {
  //     final dio = Dio();
  //     dio.options.headers["Authorization"] = "Bearer $accessToken";
  //     final response =
  //         await dio.get("https://racheeta.pythonanywhere.com/users/$userId/");
  //
  //     if (response.statusCode == 200) {
  //       final userData = response.data;
  //       debugPrint("Refreshed user data: $userData");
  //
  //       // Update SharedPreferences with new data
  //       await prefs.setString("full_name", userData["full_name"]);
  //       await prefs.setString("email", userData["email"]);
  //       await prefs.setString(
  //           "gps_location", userData["gps_location"] ?? "N/A");
  //     } else {
  //       debugPrint("Failed to refresh user state: ${response.statusCode}");
  //     }
  //   } else {
  //     debugPrint("User ID or access token missing");
  //   }
  // }

  // Create a user and add to the backend
  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    print("[📤] Sending user data to server: $userData");

    try {
      final response = await dio.post('/users/', data: userData);
      print("[✅] Server responded successfully: ${response.data}");

      final userModel = UserModel.fromJson(response.data);
      print("[🔄] Parsed UserModel: ${userModel.toJson()}");

      return userModel;
    } catch (e, s) {
      print("[❌] Error during createUser:");

      if (e is DioError) {
        print("[🌐] DioError detected:");
        print("Type: ${e.type}");
        print("Message: ${e.message}");
        print("Request Path: ${e.requestOptions.path}");
        print("Status Code: ${e.response?.statusCode}");
        print("Response Data: ${e.response?.data}");
        print("Headers: ${e.response?.headers}");
        print("Full Error Object: $e");
      } else {
        print("Non-Dio Error: $e");
      }

      print("StackTrace: $s");

      rethrow;
    }
  }


// In your PatientRetroDisplayGetProvider
  Future<Map<String, dynamic>> saveUserProfile(
      Map<String, dynamic> userData) async {
    try {
      // _apiClient.createUser(userData) returns a UserModel (for example)
      final createdUserModel = await _apiClient.createUser(userData);

      // Convert that UserModel to a map
      final map = createdUserModel.toJson();

      debugPrint("User saved successfully: $map");
      return map; // <-- Return the map so the caller can access it
    } catch (e) {
      if (e is DioError && e.response != null) {
        debugPrint("Server response u idiot patient: ${e.response?.data}");
      }
      debugPrint("Error saving user: $e");
      rethrow; // Ensure the error propagates
    }
  }

  Future<void> registerUser(UserModel user) async {
    try {
      final response = await _apiClient.createUser(user.toJson());
      debugPrint("Server response: ${response.toJson()}");
    } catch (e) {
      debugPrint("Error registering user: $e");
      rethrow;
    }
  }

  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    debugPrint("<=== Starting Image Upload ===>");
    try {
      // Prepare the FormData
      final formData = FormData.fromMap({
        "profile_image": await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        "user_id": userId,
      });

      debugPrint("Prepared FormData: ${formData.fields}");
      debugPrint("Image Path: ${imageFile.path}");
      debugPrint("Uploading image for User ID: $userId");

      // Send the POST request
      final response = await dio.post(
        'https://racheeta.pythonanywhere.com/users/$userId/',
        data: formData,
      );

      // Log the response details
      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Data: ${response.data}");

      // Check response for success
      if (response.statusCode == 200 || response.statusCode == 201) {
        final uploadedImageUrl = response.data['profile_image'];
        debugPrint("Image uploaded successfully: $uploadedImageUrl");
        return uploadedImageUrl; // Return the image URL
      } else {
        debugPrint("Image upload failed with status: ${response.statusCode}");
        debugPrint("Error Details: ${response.data}");
        throw Exception("Failed to upload profile image.");
      }
    } catch (e) {
      debugPrint("Exception during image upload: $e");
      return null; // Return failure
    } finally {
      debugPrint("<=== Image Upload Process Completed ===>");
    }
  }

  Future<UserModel?> fetchCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) {
        throw Exception("User ID not found in SharedPreferences");
      }

      final user = await _apiClient.getUserById(userId);
      debugPrint("User data fetched successfully: ${user.toJson()}");
      return user;
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
        throw Exception("User ID not found in SharedPreferences");
      }

      await _apiClient.updateUser(userId, updatedData);
      debugPrint("User profile updated successfully.");
    } catch (e) {
      debugPrint("Error updating user profile: $e");
      throw e;
    }
  }

  // Future<void> updateToken(String newToken) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString("access_token", newToken);
  //   dio.options.headers["Authorization"] = "JWT $newToken";
  //   debugPrint("Provider token updated to $newToken");
  // }

  Future<String?> authenticateUser(String email, String password) async {
    try {
      final response = await dio.post(
        "https://racheeta.pythonanywhere.com/login/",
        data: {
          "email": email,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        final accessToken = response.data["access"];
        final refreshToken = response.data["refresh"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("access_token", accessToken);
        await prefs.setString("refresh_token", refreshToken);

        return accessToken; // Return the access token
      } else {
        throw Exception("Authentication failed");
      }
    } catch (e) {
      print("Error during authentication: $e");
      return null;
    }
  }

  Future<void> refreshUserState() async {
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

        // Update SharedPreferences
        await prefs.setString('user_id', userData["user_id"]);
        await prefs.setString("full_name", userData["full_name"]);
        await prefs.setString("email", userData["email"]);
        await prefs.setString(
            "gps_location", userData["gps_location"] ?? "N/A");
        await prefs.setString('phone_number', userData["phone_number"]);
        await prefs.setString('gender', userData["gender"]);
        debugPrint("User state refreshed: $userData");

        // Notify listeners for state update if needed
        notifyListeners();
      } else {
        debugPrint("Failed to refresh user state: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error in refreshUserState: $e");
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
}
