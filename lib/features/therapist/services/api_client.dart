import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/therapist_model.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://racheeta.pythonanywhere.com/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @POST("/therapists/")
  Future<TherapistModel> createTherapist(
      @Body() Map<String, dynamic> therapist);

  @GET("/therapists/")
  Future<List<TherapistModel>> fetchTherapists();

  @GET("/therapists/{id}/")
  Future<TherapistModel> getTherapistById(@Path("id") String id);

  @PATCH("/therapists/{id}/")
  Future<TherapistModel> updateTherapist(
    @Path("id") String id,
    @Body() Map<String, dynamic> therapist,
  );

  @DELETE("/therapists/{id}/")
  Future<void> deleteTherapist(@Path("id") String id);
}
