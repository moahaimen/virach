// lib/features/medical_centre/providers/medical_centers_providers.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/medical_centers_model.dart';
import '../services/api_client.dart';
import '../../doctors/models/doctor_request_model.dart';

class MedicalCentersRetroDisplayGetProvider with ChangeNotifier {
  late final MedicalCentersApiClient _api;
  final Dio _dio;

  MedicalCentersRetroDisplayGetProvider(String token)
      : _dio = Dio() {
    _setAuthToken(token);
    _api = MedicalCentersApiClient(_dio);
  }

  /// Update both stored token & header
  Future<void> updateToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    _setAuthToken(token);
    notifyListeners();
  }

  void _setAuthToken(String token) {
    if (token.isEmpty) {
      _dio.options.headers.remove('Authorization');
    } else {
      _dio.options.headers['Authorization'] = 'JWT $token';
    }
  }

  /// Own `/me/` data
  Map<String, dynamic>? _meData;
  Map<String, dynamic>? get meData => _meData;
  Future<void> fetchMe() async {
    final resp = await _dio.get('/me/');
    if (resp.statusCode == 200) {
      _meData = resp.data as Map<String, dynamic>;
      notifyListeners();
    } else {
      throw Exception('fetchMe failed: ${resp.statusCode}');
    }
  }

  /// Medical‑centres list
  List<MedicalCentersModel> _medicalCenters = [];
  List<MedicalCentersModel> get medicalCenters => _medicalCenters;

  Future<List<MedicalCentersModel>> fetchMedicalCenters() async {
    final list = await _api.fetchMedicalCenters();
    _medicalCenters = list;
    notifyListeners();
    return list;
  }

  Future<MedicalCentersModel?> createMedicalCenterWithUser({
    required Map<String, dynamic> user,
    required String centerName,
    required String directorName,
    required String bio,
    required String availabilityTime,
    required bool advertise,
    String? address,
    String? advertisePrice,
    String? advertiseDuration,
    String? profileImage,
  }) async {
    final userId = user['id']?.toString();
    if (userId == null || userId.isEmpty) {
      throw ArgumentError('Cannot create medical center without a created user id');
    }
    final payload = {
      'user': {'id': userId},
      'center_name': centerName,
      'director_name': directorName,
      'bio': bio,
      'availability_time': availabilityTime,
      'advertise': advertise,
      if (address != null) 'address': address,
      if (advertisePrice != null) 'advertise_price': advertisePrice,
      if (advertiseDuration != null) 'advertise_duration': advertiseDuration,
      if (profileImage != null) 'profile_image': profileImage,
    };
    final created = await _api.createMedicalCenters(payload);
    _medicalCenters.add(created);
    notifyListeners();
    return created;
  }

  Future<MedicalCentersModel?> updateMedicalCenter(
      String id, {
        String? centerName,
        String? directorName,
        String? bio,
        String? availabilityTime,
        bool? advertise,
        String? address,
        String? advertisePrice,
        String? advertiseDuration,
        String? profileImage,
      }) async {
    final payload = <String, dynamic>{
      if (centerName != null) 'center_name': centerName,
      if (directorName != null) 'director_name': directorName,
      if (bio != null) 'bio': bio,
      if (availabilityTime != null) 'availability_time': availabilityTime,
      if (advertise != null) 'advertise': advertise,
      if (address != null) 'address': address,
      if (advertisePrice != null) 'advertise_price': advertisePrice,
      if (advertiseDuration != null) 'advertise_duration': advertiseDuration,
      if (profileImage != null) 'profile_image': profileImage,
    };
    final updated = await _api.updateMedicalCenters(id, payload);
    final idx = _medicalCenters.indexWhere((c) => c.id == id);
    if (idx != -1) _medicalCenters[idx] = updated;
    notifyListeners();
    return updated;
  }

  Future<void> deleteMedicalCenter(String id) async {
    await _api.deleteMedicalCenters(id);
    _medicalCenters.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  /// Advertise helpers
  Future<Map<String, dynamic>?> getActiveAd(String centerId) async {
    final center = await _api.getMedicalCenterId(centerId);
    if (center.advertise != true) return null;
    return {
      'duration': center.advertiseDuration,
      'start_date': center.createDate,
      'end_date': center.updateDate,
    };
  }

  Future<void> updateAdvertisement({
    required String centerId,
    required bool advertise,
    required String advertisePrice,
    required String advertiseDuration,
  }) async {
    await _dio.patch(
      '/medical-centers/$centerId/',
      data: {
        'advertise': advertise,
        'advertise_price': advertisePrice,
        'advertise_duration': advertiseDuration,
      },
    );
  }

  /// Join‑requests
  Future<List<DoctorRequestModel>> fetchMyJoinRequests({
    bool isArchived = false,
  }) =>
      _api.fetchMyJoinRequests(isArchived);
}
