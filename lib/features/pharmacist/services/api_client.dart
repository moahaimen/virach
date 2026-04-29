import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/pharma_model.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://racheeta.pythonanywhere.com/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @POST("/pharmacists/")
  Future<PharmaModel> createPharmacy(@Body() Map<String, dynamic> pharmacy);

  @GET("/pharmacists/")
  Future<List<PharmaModel>> fetchPharmacies();

  /// Get a single nurse by ID:
  @GET("/pharmacists/{id}/")
  Future<PharmaModel> getPharmacyById(@Path("id") String id);

  @PATCH("/pharmacists/{id}/")
  Future<PharmaModel> updatePharmacy(
    @Path("id") String id,
    @Body() Map<String, dynamic> pharmacy,
  );

  @DELETE("/pharmacists/{id}/")
  Future<void> deletePharmacy(@Path("id") String id);
}
