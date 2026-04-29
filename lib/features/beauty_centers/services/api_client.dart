import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/beauty_centers_model.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://racheeta.pythonanywhere.com/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @POST("/beauty-centers/")
  Future<BeautyCentersModel> createBeautyCenters(
      @Body() Map<String, dynamic> beautyCenter);

  @GET("/beauty-centers/")
  Future<List<BeautyCentersModel>> fetchBeautyCenters();

  // Get a single beauty-centers by ID:
  @GET("/beauty-centers/{id}/")
  Future<BeautyCentersModel> getHospitalById(@Path("id") String id);

  @PATCH("/beauty-centers/{id}/")
  Future<BeautyCentersModel> updateBeautyCenters(
      @Path("id") String id, @Body() Map<String, dynamic> beautyCenter);

  @DELETE("/beauty-centers/{id}/")
  Future<void> deleteBeautyCenters(@Path("id") String id);
}
