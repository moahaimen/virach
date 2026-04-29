import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import '../../../../constansts/constants.dart';
import '../models/login_model.dart';
part 'api_client.g.dart';

@RestApi(baseUrl: baseUrl)
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @POST("/login/")
  Future<LoginResponse> login(@Body() Map<String, dynamic> body);
}
