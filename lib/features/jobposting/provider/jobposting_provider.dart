import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../doctors/models/user_model.dart';
import '../services/api_client.dart';
import '../models/jobposting_model.dart';

class JobPostingRetroDisplayGetProvider with ChangeNotifier {
  late ApiClient _apiClient;
  Dio dio = Dio();

  List<JobPostingModel> _jobPostings = [];
  List<JobPostingModel> get jobPostings => _jobPostings;

  JobPostingRetroDisplayGetProvider(String token) {
    dio.options.headers["Authorization"] = "JWT $token";
    _apiClient = ApiClient(dio);
  }
  Future<List<UserModel>> fetchApplicantsForJob(String jobId) async {
    try {
      final response = await dio.get('/job-postings/$jobId/applicants');

      // Assuming the response is a List of user objects
      final List<dynamic> data = response.data;
      return data.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
  ///JobPosting Functions

  Future<void> fetchAllJobPostings() async {
    try {
      final response = await _apiClient.getAllJobPostings();
      _jobPostings = response;
      notifyListeners();
    } catch (e) {
      print("Error fetching job postings: $e");
    }
  }

  Future<JobPostingModel?> createJobPosting(JobPostingModel jobPosting) async {
    try {
      final response = await _apiClient.createJobPosting(jobPosting.toJson());
      _jobPostings.add(response);
      notifyListeners();
      return response;
    } catch (e) {
      print("Error creating job posting: $e");
      return null;
    }
  }

  Future<void> updateJobPosting(JobPostingModel jobPosting) async {
    try {
      await _apiClient.updateJobPosting(jobPosting.id!, jobPosting.toJson());
      fetchAllJobPostings();
    } catch (e) {
      print("Error updating job posting: $e");
    }
  }

  Future<void> deleteJobPosting(String id) async {
    try {
      await _apiClient.deleteJobPosting(id);
      _jobPostings.removeWhere((job) => job.id == id);
      notifyListeners();
    } catch (e) {
      print("Error deleting job posting: $e");
    }
  }

  /// Fetch job postings for the *current user* (service provider) only
  Future<void> fetchJobPostingsForUser(String userId) async {
    try {
      print(">>> [DEBUG] Fetching job postings for userId: $userId");

      final response = await _apiClient.getJobPostings(userId);

      // Debugging: Print the raw response from the API
      print(
          ">>> [DEBUG] Raw API Response: ${response.map((job) => job.toJson()).toList()}");

      _jobPostings = response;

      // Debugging: Print the number of job postings received
      print(">>> [DEBUG] Total Job Postings Retrieved: ${_jobPostings.length}");

      notifyListeners();
    } catch (e) {
      print(">>> [ERROR] Error fetching job postings for userId: $userId");
      print("    - Error: $e");

      if (e is DioError) {
        print(">>> [ERROR] DioError Details:");
        print("    - Request URL: ${e.requestOptions.uri}");
        print("    - Request Headers: ${e.requestOptions.headers}");
        print("    - Request Method: ${e.requestOptions.method}");
        print("    - Request Data: ${e.requestOptions.data}");
        print("    - Response Status Code: ${e.response?.statusCode}");
        print("    - Response Data: ${e.response?.data}");
      }
    }
  }
}
