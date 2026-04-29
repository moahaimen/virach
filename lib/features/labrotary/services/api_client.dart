import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/labs_model.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://racheeta.pythonanywhere.com/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @POST("/laboratories/")
  Future<LabsModel> createLaboratory(@Body() Map<String, dynamic> laboratory);

  @GET("/laboratories/")
  Future<List<LabsModel>> fetchLaboratories();

  /// Get a single laboratories by ID:
  @GET("/laboratories/{id}/")
  Future<LabsModel> getLaboratoryById(@Path("id") String id);

  @PATCH("/laboratories/{id}/")
  Future<LabsModel> updateLaboratory(
    @Path("id") String id,
    @Body() Map<String, dynamic> laboratory,
  );

  @DELETE("/laboratories/{id}/")
  Future<void> deleteLaboratory(@Path("id") String id);
}
