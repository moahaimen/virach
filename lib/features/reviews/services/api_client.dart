import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../reviews/models/review_model.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://racheeta.pythonanywhere.com/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // Fetch reviews for a doctor
  @GET("/reviews/")
  Future<List<ReviewModel>> getReviews(
    @Queries() Map<String, dynamic> queries,
  );
}
