import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/applicants_model.dart';
import '../services/api_client.dart';

class ApplicantsProvider with ChangeNotifier {
  late ApiClient _apiClient;
  late Dio _dio;
  // Local cache of applicants
  List<ApplicantsModel> _applicants = [];
  List<ApplicantsModel> get applicants => _applicants;
  static const _cacheKeyPrefix = 'cached_applicants_for_job_';
  ApplicantsProvider(String token) {
    _dio = Dio()
      ..options.baseUrl = 'https://racheeta.pythonanywhere.com/' // ⬅️ حدّده هنا
      ..options.headers['Authorization'] = 'JWT $token';

    _apiClient = ApiClient(_dio); // مرّر الـ Dio إلى Retrofit
  }

  /// In your ApplicantsProvider:
  Future<void> fetchAllApplications() async {
    final response = await _dio.get('/applications/');        // no query params
    final data = response.data as List;
    _applicants = data.map((j) => ApplicantsModel.fromJson(j)).toList();
    notifyListeners();
  }

  /// Load cached applicants for a job
  Future<List<ApplicantsModel>> _loadFromCache(String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$_cacheKeyPrefix$jobId');
    if (jsonString == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map((j) => ApplicantsModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Save applicants list to cache
  Future<void> _saveToCache(String jobId, List<ApplicantsModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString =
    jsonEncode(list.map((a) => a.toJson()).toList());
    await prefs.setString('$_cacheKeyPrefix$jobId', jsonString);
  }


  // =========== CREATE ===========
  //─────────────────────────────────────────────────────────────────────────────
//  ApplicantsProvider   –  method: createApplicant
//─────────────────────────────────────────────────────────────────────────────
// ➋ Replace the whole method
  Future<ApplicantsModel?> createApplicant(ApplicantsModel model) async {
    //------------------------------------------------------------------
    // 0.  Prepare JSON map
    //------------------------------------------------------------------
    final body = model.toJson();
    body.remove('id');                //                🔹 keep this
    debugPrint('🔧 (ApplicantsProvider) Body before POST  →  $body');

    //------------------------------------------------------------------
    // 1.  Execute request
    //------------------------------------------------------------------
    try {
      debugPrint('🚀  POST  ${_dio.options.baseUrl}applications/');
      final res = await _apiClient.createApplicant(body);
      debugPrint('✅ 200  Success – created application ${res.id}');
      _applicants.add(res);
      notifyListeners();
      return res;

    } on DioError catch (e) {

      //----------------------------------------------------------------
      // 2.  Detailed error logging
      //----------------------------------------------------------------
      debugPrint('❌ DioError while POST /applications/');
      debugPrint('   • method       : ${e.requestOptions.method}');
      debugPrint('   • url          : ${e.requestOptions.path}');
      debugPrint('   • status code  : ${e.response?.statusCode}');
      debugPrint('   • request body : ${e.requestOptions.data}');

      if (e.response != null) {
        debugPrint('   • raw response : ${e.response?.data}');

        // If backend returned field‑specific errors (Django‑REST, DRF...)
        if (e.response!.data is Map) {
          final errMap = Map<String, dynamic>.from(e.response!.data);
          errMap.forEach((field, msg) {
            debugPrint('   ↳ field "$field" → $msg');
          });
        } else {
          debugPrint('   • response (pretty): ${jsonEncode(e.response!.data)}');
        }
      }

      return null;
    } catch (e, s) {
      debugPrint('💥 Unexpected exception: $e');
      debugPrint('🔍 StackTrace:\n$s');
      return null;
    }
  }

  // =========== FETCH ALL ===========
  Future<void> fetchAllApplicants() async {
    try {
      final result = await _apiClient.getAllApplicants();
      _applicants = result;
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching applicants: $e");
    }
  }

  // =========== GET BY ID ===========
  Future<ApplicantsModel?> getApplicantById(String id) async {
    try {
      final applicant = await _apiClient.getApplicantById(id);
      return applicant;
    } catch (e) {
      debugPrint("Error getting applicant by ID: $e");
      return null;
    }
  }

  Future<void> fetchCurrentUserApplications(String jobSeekerId) async {
    debugPrint('🌐 ApplicantsProvider → GET /applications/?job_seeker=$jobSeekerId');

    try {
      final result = await _apiClient.fetchApplicantsByJobSeekerId(jobSeekerId);
      debugPrint('✅ server responded with ${result.length} rows');

      // ─── Hydrate each applicant’s jobSeekerUser from jobSeekerId ───
      for (var applicant in result) {
        // if backend only sent an ID, not a full map
        if (applicant.jobSeekerUser == null && applicant.jobSeekerId != null) {
          final id = applicant.jobSeekerId!;
          try {
            debugPrint('🔄 fetching UserModel for jobSeekerId: $id');
            final user = await _apiClient.getUserById(id);
            applicant.jobSeekerUser = user;
          } catch (e) {
            debugPrint('⚠️ couldn’t fetch user $id: $e');
          }
        }
      }

      _applicants = result;
      notifyListeners();
    } on DioError catch (e) {
      debugPrint('❌ fetchCurrentUserApplications DioError → ${e.message}');
      debugPrint('   status=${e.response?.statusCode}  data=${e.response?.data}');
    } catch (e, s) {
      debugPrint('💥 Unexpected error: $e\n$s');
    }
  }


  // =========== UPDATE ===========
  Future<ApplicantsModel?> updateApplicant(ApplicantsModel model) async {
    // … your patch logic …
    final updated = await _apiClient.updateApplicant(model.id!, model.toJson());
    // preserve user, update list …
    final idx = _applicants.indexWhere((a) => a.id == updated.id);
    if (idx != -1) _applicants[idx] = updated;
    notifyListeners();
    // ✅ also refresh cache
    if (model.jobSeekerId != null) {
      await _saveToCache(model.jobSeekerId!, _applicants);
    }
    return updated;
  }

  // =========== DELETE ===========
  Future<bool> deleteApplicant(String id) async {
    final ok = await _apiClient.deleteApplicant(id).then((_) => true).catchError((_) => false);
    if (ok) {
      _applicants.removeWhere((a) => a.id == id);
      notifyListeners();
      // ✅ update cache too (use any jobId—they all share the same list here)
      if (_applicants.isNotEmpty) {
        await _saveToCache(_applicants.first.job ?? '', _applicants);
      }
    }
    return ok;
  }
  /// ← New: status-only update
  /// status‑only PATCH  → returns true on success / false on failure
  Future<bool> updateApplicantStatusOnly(String id, String newStatus) async {
    // 1) update in‑memory list
    final idx = _applicants.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _applicants[idx].applicationStatus = newStatus;
      notifyListeners();
    }

    // 2) PATCH to server
    try {
      await _apiClient.updateApplicant(id, {'application_status': newStatus});
      return true;          // <──────  must return a bool
    } catch (e) {
      debugPrint('status‑only PATCH failed → $e');
      return false;
    }
  }

  /// in ApplicantsProvider
  Future<bool> patchStatus(String id, String newStatus) async {
    try {
      await _apiClient.updateApplicant(id, {'application_status': newStatus});
      return true;    // we don’t care about the body
    } catch (e) {
      debugPrint('patchStatus failed → $e');
      return false;
    }
  }


  // =========== FETCH APPLICANTS FOR A SPECIFIC JOB SEEKER ===========
  Future<void> fetchApplicantsByJobSeekerId(String jobSeekerId) async {
    try {
      final result = await _apiClient.fetchApplicantsByJobSeekerId(jobSeekerId);
      _applicants = result;
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching applicants by jobSeekerId: $e");
    }
  }

  // =========== FETCH APPLICANTS FOR A SPECIFIC JOB ===========
  Future<void> fetchApplicantsByJobId(String jobId) async {
    // 1️⃣ Load from cache first
    final cached = await _loadFromCache(jobId);
    if (cached.isNotEmpty) {
      _applicants = cached;
      notifyListeners();
    }

    // 2️⃣ Fetch fresh from network
    try {
      final result = await _apiClient.fetchApplicantsByJobId(jobId);

      // hydrate missing user details as before …
      for (var a in result) {
        if (a.jobSeekerUser == null && a.jobSeekerId != null) {
          try {
            a.jobSeekerUser = await _apiClient.getUserById(a.jobSeekerId!);
          } catch (_) {}
        }
      }

      _applicants = result;
      notifyListeners();

      // 3️⃣ Update cache
      await _saveToCache(jobId, result);
    } catch (e) {
      debugPrint("❌ fetchApplicantsByJobId failed: $e");
    }
  }


// Future<void> fetchCurrentUserApplications(String jobSeekerId) async {
  //   try {
  //     final result = await _apiClient.fetchApplicantsByJobSeekerId(jobSeekerId);
  //     _applicants = result;
  //     notifyListeners();
  //   } catch (e) {
  //     debugPrint("Error fetching current user's applications: $e");
  //   }
  // }

}
