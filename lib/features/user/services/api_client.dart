import 'package:dio/dio.dart';
import 'package:racheeta/features/user/model/user_model.dart';
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://racheeta.pythonanywhere.com/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @POST("/users/")
  Future<UserModel> createUser(@Body() Map<String, dynamic> user);
  @GET("/users/")
  Future<List<UserModel>> getAllUsers();
}
