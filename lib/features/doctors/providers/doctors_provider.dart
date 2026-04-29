import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../reviews/models/review_model.dart';
import '../../reviews/services/api_client.dart'
    as ReviewApi; // Aliased to avoid conflicts
import '../models/doctor_request_model.dart';
import '../models/user_model.dart';
import '../services/api_client.dart'; // Main API client for doctors
import '../models/doctors_model.dart'; // Ensure model is correct

class DoctorRetroDisplayGetProvider with ChangeNotifier {
  late ApiClient _apiClient;
  late ReviewApi.ApiClient _reviewApiClient;
  final Dio dio = Dio();
  List<DoctorModel> _doctors = [];

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  Map<String, dynamic>? _meData;
  Map<String, dynamic>? get meData => _meData;
  DoctorModel? _currentDoctor;
  DoctorModel? get currentDoctor => _currentDoctor;

  /// Constructor: initialize Dio header and clients
  DoctorRetroDisplayGetProvider(String token) {
    print("… Received Token: $token");
    setAuthToken(token);                // ← centralized header setter
    _apiClient = ApiClient(dio);
    _reviewApiClient = ReviewApi.ApiClient(dio);

    print("… Initialized with Header: ${dio.options.headers['Authorization']}");
  }

  /// Update the JWT token for all future requests
  void setAuthToken(String token) {
    if (token.isEmpty) {
      dio.options.headers.remove('Authorization');
    } else {
      dio.options.headers['Authorization'] = 'JWT $token';
    }
    // If your ApiClient holds onto Dio, you could recreate it here:
    // _apiClient = ApiClient(dio);
    // _reviewApiClient = ReviewApi.ApiClient(dio);
    notifyListeners();
  }

  /// Look up this user’s doctor-profile id via /doctor/?user=<user_id>
  /// Returns null if the account has no doctor profile.
  Future<String?> fetchDoctorIdByUser(String userId) async {
    try {
      // 1) Pull freshest token directly from SharedPreferences as a fallback
      final prefs  = await SharedPreferences.getInstance();
      final token  = prefs.getString('access_token') ?? '';
      if (token.isEmpty) {
        debugPrint('❌ No token in prefs – cannot query doctor profile');
        return null;
      }

      // 2) Ensure dio header is correct *right now*
      dio.options.headers['Authorization'] = 'JWT $token';

      // 3) Call the filtered list
      final resp = await dio.get(
        'https://racheeta.pythonanywhere.com/doctor/',
        queryParameters: {'user': userId},
      );

      if (resp.statusCode == 200 &&
          resp.data is List &&
          (resp.data as List).isNotEmpty) {
        final doctorId = resp.data[0]['id'] as String?;
        debugPrint('✅ fetchDoctorIdByUser → $doctorId');
        return doctorId;
      } else {
        debugPrint('⚠️ No doctor profile for user $userId');
      }
    } catch (e) {
      debugPrint('❌ fetchDoctorIdByUser error: $e');
    }
    return null;
  }


  /// Returns the HSP uuid (role.details.id) from /me/
  Future<String?> fetchMyHspId() async {
    // Assumes your dio already has JWT header set
    final resp = await dio.get('https://racheeta.pythonanywhere.com/me/');
    if (resp.statusCode == 200) {
      final me = resp.data as Map<String, dynamic>;
      // adjust path if your JSON is nested differently
      return me['role']?['details']?['id'] as String?;
    }
    return null;
  }


  bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final payloadMap = json.decode(utf8.decode(base64Url.decode(normalized)));
      final exp = payloadMap['exp'];
      if (exp == null) return true;
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiryDate);
    } catch (_) {
      return true;
    }
  }


  /// 1) createUser with default GPS location
  Future<UserModel?> createUser({
    required String email,
    required String fullName,
    required String password,
    required String role,
    required String phoneNumber,
    required String gender,
    required String gps_location,
    String? firebaseUid,
    String? fcm, // Added parameter
    bool? isActive
  }) async {
    print(">>> [createUser] Starting user creation...");

    final payload =
    {
      "email": email,
      "full_name": fullName,
      "password": password,
      "role": role,
      "phone_number": phoneNumber,
      "gps_location": gps_location,
      "gender": gender,
      "firebase_uid": firebaseUid,
      "fcm": fcm, // Added to payload
    };
  //


    print(">>> [createUser] Payload: $payload");

    try {
      // Use the existing _apiClient (which already has the JWT token set in headers)
      final createdUser = await _apiClient.createUser(payload);
      print(">>> [createUser] User created: ${createdUser.toJson()}");
      return createdUser;
    } on DioException catch (e) {
      print(">>> [ERROR] DioException: ${e.response?.data}");
      print(">>> [ERROR] Status Code: ${e.response?.statusCode}");
      print(">>> [ERROR] Headers: ${e.response?.headers}");
      throw Exception("Failed to create user: ${e.response?.data['message']}");
    } catch (e) {
      print(">>> [ERROR] Unexpected error: $e");
      throw Exception("User creation failed");
    }
  }

  Future<DoctorModel?> createDoctor(
      {required UserModel userModel, // Pass the entire user object
      required String specialty,
      required String degrees,
      required String bio,
      required String address,
      required bool isInternationalBool,
      required String country,
      required String availabilityTime,
      double? price,
      bool? voiceCall,       // ✅ مضاف
      bool? videoCall,       // ✅ مضاف

      }) async {
    print(">>> [createDoctor] Starting doctor creation...");

    // Convert your `bool` to the required 0/1:
    final isInternationalInt = isInternationalBool ? 1 : 0;

    // Build the user sub-object exactly as the server wants
    // NOTE: Possibly you need `is_active`, `is_staff`, etc.
    // which might be missing in your user object.
    // If your userModel has them set, that's fine; or forcibly set them.
    final Map<String, dynamic> userPayload = {
      "id": userModel.id,
      "email": userModel.email,
      "full_name": userModel.fullName,
      "role": userModel.role,
      "profile_image": userModel.profileImage, // or null
      "gps_location":
          userModel.gpsLocation, // "33.3152 44.3661" from createUser
      "phone_number": userModel.phoneNumber,
      "is_active": userModel.isActive ?? true, // default to true
      "is_staff": userModel.isStaff ?? false, // default to false
      "gender": userModel.gender, // or null
      "availability_time": availabilityTime, // e.g. "3pm-9pm"
      "firebase_uid": userModel.firebaseUid, // or null
    };

    final payload = {
      "user": userPayload,
      "specialty": specialty,
      "degrees": degrees,
      "bio": bio,
      "availability_time": availabilityTime,
      "is_international": isInternationalBool,
      "country": country,
      "address": address,
      "price": price,
      "voice_call": voiceCall ?? false,   // ✅ جديد
      "video_call": videoCall ?? false,   // ✅ جديد
    };

    print(">>> [createDoctor] Payload: $payload");

    try {
      final createdDoctor = await _apiClient.createDoctor(payload);
      print(
          ">>> [createDoctor] Doctor created successfully: ${createdDoctor.toJson()}");
      return createdDoctor;
    } catch (e) {
      print(">>> [createDoctor] Error creating doctor: $e");
      return null;
    }
  }

  // Fetch reviews for a doctor
  Future<List<ReviewModel>> fetchDoctorReviews(String doctorId) async {
    try {
      List<ReviewModel> reviews = await _reviewApiClient.getReviews({
        "service_provider_type": "doctor",
        "service_provider_id": doctorId,
      });
      return reviews;
    } catch (e) {
      print("Error fetching reviews: $e");
      return [];
    }
  }

// Return List<DoctorModel> instead of void
  Future<List<DoctorModel>> getDoctorsBySpecialty(String specialty) async {
    print("Calling getDoctorsBySpecialty($specialty)");
    try {
      final doctorModels = await _apiClient.getDoctorsBySpecialty(specialty);
      print("Server responded with: $doctorModels");

      _doctors = doctorModels;
      notifyListeners();
      return doctorModels;
    } catch (e) {
      print("Error fetching doctors by specialty: $e");
      return [];
    }
  }

// In DoctorRetroDisplayGetProvider
  Future<List<DoctorModel>> fetchInternationalDoctorsLocally() async {
    try {
      // 1) Fetch all doctors from your API client
      final allDocs = await _apiClient.getAllDoctors();

      // 2) Filter only those with isInternational == true
      final intlDocs =
          allDocs.where((doc) => doc.isInternational == true).toList();

      // (Optional) store them in _doctors if you want
      _doctors = intlDocs;

      // 3) Return them so the UI can use them
      return intlDocs;
    } catch (e) {
      print("Error fetching all doctors: $e");
      return [];
    }
  }

  List<DoctorModel> get doctors => _doctors;

// Fetch doctor by ID
  Future<DoctorModel?> fetchDoctorById(String doctorId) async {
    try {
      final doctor = await _apiClient.getDoctorById(doctorId);
      print("Fetched Doctor: ${doctor.toJson()}");
      return doctor;
    } catch (e) {
      print("Error fetching doctor by ID: $e");
      return null; // Handle errors gracefully
    }
  }

  Future<List<DoctorModel>> fetchAllDoctors() async {
    try {
      final response = await _apiClient.getAllDoctors();
      _doctors = response;
      notifyListeners();
      return response;
    } catch (e) {
      print("Error fetching doctors: $e");
      return [];
    }
  }
// lib/features/doctors/providers/doctor_retro_display_get_provider.dart
  Future<List<DoctorModel>> fetchDoctorsByAvailability({
    required bool isAvailable,
  }) async {
    try {
      final docs = await _apiClient.getDoctorsByAvailability(
        availableForCenter: isAvailable,
      );
      _doctors = docs;
      notifyListeners();
      return docs;
    } catch (e) {
      debugPrint('❌ fetchDoctorsByAvailability error: $e');
      return [];
    }
  }

  /// Registration functions
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
        debugPrint("Server response: ${e.response?.data}");
      }
      debugPrint("Error saving user: $e");
      rethrow; // Ensure the error propagates
    }
  }

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
      var accessToken = prefs.getString('access_token');
      if (userId == null || accessToken == null) {
        throw Exception("Missing user ID or access token.");
      }

      // Check if the token is expired
      if (isTokenExpired(accessToken)) {
        print("Refreshing expired token...");
        final refreshToken = prefs.getString('refresh_token');
        if (refreshToken == null) {
          throw Exception("No refresh token available.");
        }

        // Call the refresh token endpoint
        final response = await dio.post(
          "https://racheeta.pythonanywhere.com/refresh/",
          data: {"refresh": refreshToken},
        );

        if (response.statusCode == 200) {
          final newAccessToken = response.data["access"];
          await prefs.setString("access_token", newAccessToken);
          accessToken = newAccessToken;
          print("Token refreshed successfully.");
        } else {
          throw Exception("Failed to refresh token.");
        }
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

  Future<void> updateToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", newToken);

    dio.options.headers["Authorization"] = "JWT $newToken";
    debugPrint("Provider token updated: $newToken");

    // Notify listeners to ensure UI updates if necessary
    notifyListeners();
  }

  // void setAuthToken(String token) {
  //   dio.options.headers["Authorization"] = "JWT $token";
  //   debugPrint("Provider token updated to $token");
  // }

  Future<DoctorModel?> fetchCurrentDoctor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) {
        throw Exception("User ID not found in SharedPreferences");
      }

      final doctor = await _apiClient.getDoctorById(userId);
      debugPrint("User data fetched successfully: ${doctor.toJson()}");
      return doctor;
    } catch (e) {
      debugPrint("Error fetching user details: $e");
      return null;
    }
  }

  Future<void> updateAdvertisement({
    required String doctorId,
    required bool advertise,
    required String advertisePrice,
    required String advertiseDuration,
  }) async {
    debugPrint('>>> [updateAdvertisement] DoctorId: $doctorId');

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
      final url = 'https://racheeta.pythonanywhere.com/doctor/$doctorId/';
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

// In doctor_retro_display_get_provider.dart
  Future<void> fetchMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      if (token.isEmpty) {
        throw Exception('No access_token found in SharedPreferences');
      }

      // Make sure your `dio` has the Authorization header
      dio.options.headers['Authorization'] = 'JWT $token';

      // Example: GET https://racheeta.pythonanywhere.com/me/
      // Adjust the endpoint to match your backend
      final response = await dio.get('https://racheeta.pythonanywhere.com/me/');

      if (response.statusCode == 200) {
        _meData = response.data;
        notifyListeners();
        debugPrint('>>> [fetchMe] /me/ data = $_meData');
      } else {
        throw Exception(
            'Failed to fetch /me/ with status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('>>> [fetchMe] Error: $e');
      rethrow;
    }
  }

  /// Check if a doctor has an active advertisement
  Future<Map<String, dynamic>?> getActiveAd(String doctorId) async {
    try {
      final response = await _apiClient.getDoctorById(doctorId); // Fetch doctor
      final doctor = DoctorModel.fromJson(response.toJson()); // Parse response

      if (doctor.advertise == true) {
        // Return active advertisement details if advertise is true
        return {
          'duration': doctor.advertiseDuration,
          'start_date': doctor.createDate,
          'end_date': doctor.updateDate, // Adjust as per your backend logic
        };
      }

      return null; // No active advertisement
    } catch (e) {
      print("Error fetching active ad for doctor: $e");
      return null;
    }
  }

  /// Fetch a user's info from /users/{userId},
  /// parse the user and any embedded doctor_profile
  Future<void> fetchDoctorViaUserEndpoint(String userId) async {
    try {
      // 1) Call getUserById
      final user = await _apiClient.getUserById(userId);

      // 2) If there's a doctor_profile, that's the doctor object
      final docProfile = user.doctorProfile;
      if (docProfile != null) {
        _currentDoctor = docProfile;
      } else {
        _currentDoctor = null; // user might not be a doctor
      }

      // 3) Store the user
      _currentUser = user;
      notifyListeners();

      debugPrint("Successfully fetched user: ${user.email}");
      if (_currentDoctor != null) {
        debugPrint("Doctor profile found: ID: ${_currentDoctor!.id}");
      } else {
        debugPrint("No doctor_profile found in user data");
      }
    } catch (e) {
      debugPrint("Error fetching user/doctor via user endpoint: $e");
      _currentDoctor = null;
      _currentUser = null;
      notifyListeners();
    }
  }

  // Optional: If you want to do the saving logic here as well.
  Future<void> saveDoctorData({
    required String userId,
    required Map<String, dynamic> userPayload,
    required Map<String, dynamic> doctorPayload,
  }) async {
    try {
      // 1) PATCH /users/{userId}/
      await dio.patch("https://racheeta.pythonanywhere.com/users/$userId/",
          data: userPayload);

      // 2) If we have a currentDoctor, patch /doctor/{doctorId}/
      if (_currentDoctor?.id != null) {
        await dio.patch(
          "https://racheeta.pythonanywhere.com/doctor/${_currentDoctor!.id}/",
          data: doctorPayload,
        );
      }

      debugPrint("Doctor data saved successfully via provider.");
    } catch (e) {
      debugPrint("Error saving doctor data: $e");
    }
  }


  /// Invite a doctor to join this medical center
  Future<void> inviteDoctor(String doctorId) async {
    // 1) grab the centerId from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final centerId = prefs.getString('medical_center_id');
    if (centerId == null || centerId.isEmpty) {
      debugPrint('❌ inviteDoctor: missing medical_center_id in prefs');
      throw Exception('معرف المركز الطبي مفقود'); // bubble up
    }

    // 2) build payload
    final payload = {'doctor_id': doctorId};

    // 3) debug logging
    debugPrint('🔔 inviteDoctor() →');
    debugPrint('   centerId = $centerId');
    debugPrint('   doctorId = $doctorId');
    debugPrint('   payload  = $payload');
    debugPrint('   headers  = ${dio.options.headers}');
    debugPrint('   POST     = /medical-centers/$centerId/invite-doctor/');

    // 4) call the endpoint on your existing _apiClient
    try {
      await _apiClient.inviteDoctor(centerId, payload);
      debugPrint('✅ inviteDoctor succeeded');
    } on DioError catch (e) {
      debugPrint('❌ inviteDoctor failed: ${e.response?.statusCode} ${e.response?.data}');
      rethrow; // let the UI handle showing SnackBar
    }
  }
  Future<List<DoctorRequestModel>> fetchDoctorRequests({
    required String centerId,
    bool isArchived = false,
  }) async {
    // 1) Log input
    debugPrint('🔍 [fetchDoctorRequests] centerId=$centerId, isArchived=$isArchived');

    // 2) Log current headers
    debugPrint('🔍 [fetchDoctorRequests] headers=${dio.options.headers}');

    try {
      // 3) Call the endpoint
      final raw = await _apiClient.getDoctorRequests(
        center:    centerId,
        isArchived: isArchived,
      );

      // 4) Log the raw JSON
      debugPrint('🔍 [fetchDoctorRequests] raw response ($raw.length items) = $raw');

      // 5) Parse into models with per‑item logging
      final list = raw.map((json) {
        debugPrint('🔍 [fetchDoctorRequests] parsing json=$json');
        return DoctorRequestModel.fromJson(json);
      }).toList();

      debugPrint('🔍 [fetchDoctorRequests] parsed ${list.length} requests');
      return list;

    } on DioError catch (e) {
      // 6) Detailed error logging
      debugPrint('🔍 [fetchDoctorRequests] DioError → '
          'status=${e.response?.statusCode} '
          'data=${e.response?.data}');
      return [];
    } catch (e) {
      debugPrint('🔍 [fetchDoctorRequests] unexpected error: $e');
      return [];
    }
  }
  /// Accept a centre invite and refresh doctor data
  Future<void> approveInvite(String centerId) async {
    // 1) We need the doctor’s UUID first
    final doctorId = _currentDoctor?.id;
    if (doctorId == null) {
      throw Exception('Doctor ID is null – fetch doctor profile first.');
    }

    // 2) Hit the endpoint  ➜  /doctor/{uuid}/approve-request/
    await _apiClient.approveCenterInvite(
      doctorId,
      {"center_id": centerId},
    );

    // 3) Immediately pull the fresh record so we get the new flags + centre data
    final updated = await _apiClient.getDoctorById(doctorId);

    // 4) Replace local cache and notify UI
    _currentDoctor = updated;
    notifyListeners();
  }


  Future<void> rejectInvite(String centerId) async {
    final doctorId = _currentDoctor?.id;
    if (doctorId == null) throw Exception('Doctor ID is null.');

    await _apiClient.rejectCenterInvite(
      doctorId,
      {"center_id": centerId},
    );

    // status now: rejected=true, is_archived=true
    _currentDoctor = await _apiClient.getDoctorById(doctorId);
    notifyListeners();
  }

  Future<void> leaveCenter() async {
    final doctorId = _currentDoctor?.id;
    if (doctorId == null) throw Exception('Doctor ID is null.');

    await _apiClient.leaveCenter(doctorId);

    // backend sets available_for_center=true, is_archived=true
    _currentDoctor = await _apiClient.getDoctorById(doctorId);
    notifyListeners();
  }

  Future<void> joinCenter(String centerId) async {
    final doctorId = _currentDoctor?.id;
    if (doctorId == null) throw Exception('Doctor ID is null.');

    await _apiClient.requestJoinCenter(
      doctorId,
      {"center_id": centerId},
    );

    // No local change until the centre approves; keep currentDoctor as-is
  }
  Future<void> _refreshDoctor(String doctorId) async {
    _currentDoctor = await _apiClient.getDoctorById(doctorId);
    notifyListeners();
  }

// ─── centre-invite cache ────────────────────────────────────────────
  List<DoctorRequestModel> _incomingRequests = [];
  List<DoctorRequestModel> get incomingRequests => _incomingRequests;

  /// Fetch all open centre invites for *this* doctor
  Future<void> fetchIncomingRequests() async {
    final doctorId = _currentDoctor?.id;
    if (doctorId == null) return;

    final raw = await _apiClient.getDoctorRequests(
      doctor: doctorId,
      isArchived: false,
    );

    _incomingRequests =
        raw.map((j) => DoctorRequestModel.fromJson(j)).toList();

    notifyListeners();
  }
  List<DoctorRequestModel> _myDoctorRequests = [];
  List<DoctorRequestModel> get myDoctorRequests => _myDoctorRequests;


  Future<void> fetchMyDoctorRequests({bool includeArchived = false}) async {
    final doctorId = _currentDoctor?.id;
    if (doctorId == null) {
      debugPrint('[DoctorProvider] fetchMyDoctorRequests: currentDoctor is null');
      return;
    }

    try {
      debugPrint('[DoctorProvider] fetching my doctor requests. Authorization: ${dio.options.headers['Authorization']}');
      final raw = await _apiClient.getMyDoctorRequests(); // <-- only this
      debugPrint('[DoctorProvider] getMyDoctorRequests returned ${raw.length} items: $raw');

      var filtered = raw;
      if (!includeArchived) {
        filtered = raw.where((j) => j['is_archived'] == false).toList();
      }

      _myDoctorRequests = filtered.map((j) => DoctorRequestModel.fromJson(j)).toList();
      notifyListeners();
    } on DioException catch (e) {
      debugPrint('[DoctorProvider] fetchMyDoctorRequests DioException: status=${e.response?.statusCode} data=${e.response?.data}');
    } catch (e) {
      debugPrint('[DoctorProvider] fetchMyDoctorRequests error: $e');
    }
  }
  /// Explicitly load a doctor by its UUID and cache it as currentDoctor.
  Future<void> loadDoctorById(String doctorId) async {
    try {
      final doctor = await _apiClient.getDoctorById(doctorId);
      _currentDoctor = doctor;
      notifyListeners();
      debugPrint('[DoctorProvider] loadDoctorById succeeded: id=$doctorId');
    } catch (e) {
      debugPrint('[DoctorProvider] loadDoctorById error: $e');
    }
  }


// ───────────────────────── helpers ─────────────────────────
  void _updateState({
    bool? availableForCenter,
    bool? isArchived,
    bool? rejected,
  }) {
    // update whatever DoctorModel / local vars you keep
    // notify listeners afterwards
    // doctor.availableForCenter = availableForCenter ?? doctor.availableForCenter;
    // doctor.isArchived = isArchived ?? doctor.isArchived;
    // doctor.rejected = rejected ?? doctor.rejected;
    notifyListeners();
  }



}

