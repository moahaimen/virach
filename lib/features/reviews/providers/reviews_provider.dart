import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../reviews/models/review_model.dart';
import '../services/api_client.dart'; // Make sure this is your correct path

class ReviewsRetroDisplayGetProvider with ChangeNotifier {
  late ApiClient _apiClient;

  ReviewsRetroDisplayGetProvider(String token) {
    Dio dio = Dio();
    dio.options.headers["Authorization"] = "JWT $token";
    _apiClient = ApiClient(dio);
  }

  // Fetch reviews for a doctor
  Future<List<ReviewModel>> fetchDoctorReviews(String doctorId) async {
    try {
      List<ReviewModel> reviews = await _apiClient.getReviews({
        "service_provider_type": "doctor",
        "service_provider_id": doctorId,
      });
      return reviews;
    } catch (e) {
      print("Error fetching reviews: $e");
      return [];
    }
  }
}
