import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../doctors/models/user_model.dart';
part 'api_client.g.dart';

@RestApi(baseUrl: "https://racheeta.pythonanywhere.com/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @POST("/users/")
  Future<UserModel> createUser(@Body() Map<String, dynamic> user);

  @GET("/users/")
  Future<List<UserModel>> getAllUsers();

  @GET("/users/{id}/")
  Future<UserModel> getUserById(@Path("id") String userId);

  @PATCH("/users/{id}/")
  Future<void> updateUser(
    @Path("id") String userId,
    @Body() Map<String, dynamic> updatedData,
  );
}
