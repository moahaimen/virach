import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/nurse_model.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://racheeta.pythonanywhere.com/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @POST("/nurses/")
  Future<NurseModel> createNurse(@Body() Map<String, dynamic> nurse);

  @GET("/nurses/")
  Future<List<NurseModel>> fetchNurses();

  // Get a single nurse by ID:
  @GET("/nurses/{id}/")
  Future<NurseModel> getNurseById(@Path("id") String id);

  @PATCH("/nurses/{id}/")
  Future<NurseModel> updateNurse(
    @Path("id") String id,
    @Body() Map<String, dynamic> nurse,
  );

  @DELETE("/nurses/{id}/")
  Future<void> deleteNurse(@Path("id") String id);
}
