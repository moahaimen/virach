import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/jobposting_model.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://racheeta.pythonanywhere.com/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  ///JOBPOSTINGS
// Create a job posting
  @POST("/job-postings/")
  Future<JobPostingModel> createJobPosting(
      @Body() Map<String, dynamic> jobPosting);

// Get all job postings
  @GET("/job-postings/")
  Future<List<JobPostingModel>> getAllJobPostings();

// Get a specific job posting by ID
  @GET("/job-postings/{id}/")
  Future<JobPostingModel> getJobPostingById(@Path("id") String id);

// Update a job posting
  @PATCH("/job-postings/{id}/")
  Future<JobPostingModel> updateJobPosting(
      @Path("id") String id, @Body() Map<String, dynamic> jobPosting);

// Delete a job posting
  @DELETE("/job-postings/{id}/")
  Future<void> deleteJobPosting(@Path("id") String id);

  //// Fetch job postings for a given service provider
  @GET("/job-postings/")
  Future<List<JobPostingModel>> getJobPostings(
    @Query("service_provider") String? providerId,
  );
}
