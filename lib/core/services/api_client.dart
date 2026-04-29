import 'package:dio/dio.dart';
import 'package:racheeta/core/models/posts_model.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

import '../../features/common_screens/signup_login/models/login_model.dart';
part 'api_client.g.dart';

@RestApi(baseUrl: "https://racheeta.pythonanywhere.com/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @GET("/posts")
  Future<List<PostsModel>> getUsers();

  @POST("/login/") // Replace '/login' with your actual endpoint
  Future<LoginResponse> login(@Body() Map<String, dynamic> loginData);
}
