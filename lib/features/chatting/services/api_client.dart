import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/chatting_model.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://racheeta.pythonanywhere.com/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // Fetch messages between sender and receiver
  @GET("/message/")
  Future<List<ChattingModel>> getMessages(
    @Queries() Map<String, dynamic> queries,
  );

  // Send a new message
  @POST("/message/")
  Future<ChattingModel> sendMessage(
    @Body() Map<String, dynamic> message,
  );
}
