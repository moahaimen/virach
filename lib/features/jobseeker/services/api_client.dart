import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../doctors/models/user_model.dart';
import '../models/jobseeker_model.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://racheeta.pythonanywhere.com/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // =========== USER ENDPOINTS ===========

  @POST("/users/")
  Future<UserModel> createUser(@Body() Map<String, dynamic> user);

  @GET("/users/")
  Future<List<UserModel>> getAllUsers();
  @GET("/users/{id}/")
  Future<UserModel> getUserById(@Path("id") String id);
  // =========== JOBSEEKER ENDPOINTS ===========

  /// Create a JobSeeker
  @POST("/jobseekers/")
  Future<JobSeekerModel> createJobSeeker(
      @Body() Map<String, dynamic> jobSeekerData);

  /// Fetch all JobSeekers
  @GET("/jobseekers/")
  Future<List<JobSeekerModel>> fetchJobSeekers();

  // Add this method to the ApiClient
  @GET("/jobseekers/")
  Future<List<JobSeekerModel>> fetchJobSeekersByUserId(
      @Query("user") String userId);

  /// Fetch a single JobSeeker by ID
  @GET("/jobseekers/{id}/")
  Future<JobSeekerModel> fetchJobSeekerById(@Path("id") String id);

  @GET("/jobseekers/")
  Future<List<JobSeekerModel>> fetchJobSeekerByUserId(
    @Query("user") String userId,
  );

  /// Fetch JobSeekers by specialty.
  /// (Your backend must support something like ?specialty=something)
  @GET("/jobseekers/")
  Future<List<JobSeekerModel>> fetchJobSeekersBySpecialty(
      @Query("specialty") String specialty);

  /// Update a JobSeeker by ID (use PATCH or PUT; adjust as needed)
  @PATCH("/jobseekers/{id}/")
  Future<JobSeekerModel> updateJobSeeker(@Path("id") String jobseekerId,
      @Body() Map<String, dynamic> jobSeekerData);

  @PATCH("/users/{id}/")
  Future<UserModel> updateUser(
      @Path("id") String id, @Body() Map<String, dynamic> userData);

  /// Delete a JobSeeker by ID
  @DELETE("/jobseekers/{id}/")
  Future<void> deleteJobSeeker(@Path("id") String jobseekerId);
}
