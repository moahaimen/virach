import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../chatting/models/chatting_model.dart';
import '../models/doctors_model.dart';
import '../../notifications/model/notification_model.dart';
import '../../reviews/models/review_model.dart';
import '../models/user_model.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://racheeta.pythonanywhere.com/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // ──────────────────────── USERS ────────────────────────
  @POST("/users/")
  Future<UserModel> createUser(@Body() Map<String, dynamic> user);

  @GET("/users/{id}/")
  Future<UserModel> getUserById(@Path("id") String id);

  @GET("/users/")
  Future<List<UserModel>> getAllUsers();

  // ──────────────────────── DOCTORS ────────────────────────
  @POST("/doctor/")
  Future<DoctorModel> createDoctor(@Body() Map<String, dynamic> doctor);

  @GET("/doctor/")
  Future<List<DoctorModel>> getAllDoctors();

  @GET("/doctor/{id}/")
  Future<DoctorModel> getDoctorById(@Path("id") String id);

  @GET("/doctor/")
  Future<List<DoctorModel>> getDoctorsBySpecialty(
      @Query("specialty") String specialty,
      );

  @GET("/doctor/")
  Future<List<DoctorModel>> getDoctorsByAvailability({
    @Query('available_for_center') required bool availableForCenter,
    @Query('is_archived') bool isArchived = false,
  });

  @PATCH("/doctor/{id}/")
  Future<DoctorModel> updateDoctor(
      @Path("id") String id,
      @Body() Map<String, dynamic> doctorData,
      );

  // ─── Doctor ⇄ Center (doctor-side actions) ───
  @POST("/doctor/{doctorId}/approve-request/")
  Future<void> approveCenterInvite(
      @Path("doctorId") String doctorId,
      @Body() Map<String, String> body, // {"center_id": "{uuid}"}
      );

  @POST("/doctor/{doctorId}/reject-request/")
  Future<void> rejectCenterInvite(
      @Path("doctorId") String doctorId,
      @Body() Map<String, String> body, // {"center_id": "{uuid}"}
      );

  @POST("/doctor/{doctorId}/leave-center/")
  Future<void> leaveCenter(@Path("doctorId") String doctorId);

  @POST("/doctor/{doctorId}/join-center/")
  Future<void> requestJoinCenter(
      @Path("doctorId") String doctorId,
      @Body() Map<String, String> body, // {"center_id": "{uuid}"}
      );

  // ─── Center-side invite / request management ───
  @POST('/medical-centers/{centerId}/invite-doctor/')
  Future<void> inviteDoctor(
      @Path('centerId') String centerId,
      @Body() Map<String, String> body, // {"doctor_id": "{uuid}"}
      );

  @GET("/doctor-request/")
  Future<List<Map<String, dynamic>>> getDoctorRequests({
    @Query("doctor") String? doctor,
    @Query("center") String? center,
    @Query("is_archived") bool? isArchived,
  });

  /// Doctor’s own join requests (uses authenticated doctor context)
  @GET("/doctor-request/my-requests/")
  Future<List<Map<String, dynamic>>> getMyDoctorRequests();

}
