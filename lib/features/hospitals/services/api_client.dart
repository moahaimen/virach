import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../doctors/models/user_model.dart';
import '../models/hospitals_model.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://racheeta.pythonanywhere.com/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @POST("/hospitals/")
  Future<HospitalModel> createHospital(@Body() Map<String, dynamic> hospital);

  @GET("/hospitals/")
  Future<List<HospitalModel>> fetchHospitals();

  @PATCH("/hospitals/{id}/")
  Future<HospitalModel> updateHospital(
    @Path("id") String id,
    @Body() Map<String, dynamic> hospital,
  );
  // Get a single hospital by ID:
  @GET("/hospitals/{id}/")
  Future<HospitalModel> getHospitalById(@Path("id") String id);

  @DELETE("/hospitals/{id}/")
  Future<void> deleteHospital(@Path("id") String id);
}
