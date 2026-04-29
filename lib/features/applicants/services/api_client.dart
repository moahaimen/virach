import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../doctors/models/user_model.dart';
import '../models/applicants_model.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://racheeta.pythonanywhere.com/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // 1) Basic CRUD
  @GET("/applications/")
  Future<List<ApplicantsModel>> getAllApplicants();

  @GET("/applications/{id}/")
  Future<ApplicantsModel> getApplicantById(@Path("id") String id);

  @GET("/users/{id}/")
  Future<UserModel> getUserById(@Path("id") String userId);


  @POST("/applications/")
  Future<ApplicantsModel> createApplicant(@Body() Map<String, dynamic> data);

  @PATCH("/applications/{id}/")
  Future<ApplicantsModel> updateApplicant(
    @Path("id") String id,
    @Body() Map<String, dynamic> data,
  );

  @DELETE("/applications/{id}/")
  Future<void> deleteApplicant(@Path("id") String id);

  // 2) Filtering by jobSeeker ID
  //    This must match your backend's query param, e.g., ?job_seeker=...
  @GET("/applications/")
  Future<List<ApplicantsModel>> fetchApplicantsByJobSeekerId(
    @Query("job_seeker") String jobSeekerId,
  );

  // 3) If you also want to filter by job ID:
  @GET("/applications/")
  Future<List<ApplicantsModel>> fetchApplicantsByJobId(
    @Query("job") String jobId,
  );
}
