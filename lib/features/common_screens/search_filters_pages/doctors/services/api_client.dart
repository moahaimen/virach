import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/doctor_model.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://racheeta.pythonanywhere.com/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // Method to create a doctor
  @POST("/doctor/")
  Future<DoctorAPI> createDoctor(@Body() DoctorAPI doctor);

  // Method to get doctors based on specialty
  @GET("/doctor/")
  Future<List<DoctorAPI>> getDoctors(@Query("specialty") String specialty);
}
