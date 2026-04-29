// lib/features/medical_centre/services/api_client.dart

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/medical_centers_model.dart';
import '../../doctors/models/doctor_request_model.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://racheeta.pythonanywhere.com/")
abstract class MedicalCentersApiClient {
  factory MedicalCentersApiClient(Dio dio, {String baseUrl}) = _MedicalCentersApiClient;

  @GET("/medical-centers/")
  Future<List<MedicalCentersModel>> fetchMedicalCenters();

  @GET("/medical-centers/{id}/")
  Future<MedicalCentersModel> getMedicalCenterId(@Path("id") String id);

  @POST("/medical-centers/")
  Future<MedicalCentersModel> createMedicalCenters(
      @Body() Map<String, dynamic> payload,
      );

  @PATCH("/medical-centers/{id}/")
  Future<MedicalCentersModel> updateMedicalCenters(
      @Path("id") String id,
      @Body() Map<String, dynamic> payload,
      );

  @DELETE("/medical-centers/{id}/")
  Future<void> deleteMedicalCenters(@Path("id") String id);

  @GET("/doctor-request/my-requests/")
  Future<List<DoctorRequestModel>> fetchMyJoinRequests(
      @Query("is_archived") bool isArchived,
      );
}
