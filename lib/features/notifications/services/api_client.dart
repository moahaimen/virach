// lib/features/notifications/services/api_client.dart

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../model/notification_model.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://racheeta.pythonanywhere.com/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @POST("/notifications/")
  Future<NoticationsModel> createNotifications(
      @Body() Map<String, dynamic> notification);

  @GET("/notifications/")
  Future<List<Map<String, dynamic>>> getNotificationsByUserId(
      @Query("user") String userId);

  @GET("/notifications/count/")
  Future<int> getNotificationsCount(@Query("user") String userId);

  @PATCH("/notifications/{id}/")
  Future<NoticationsModel> patchNotification(
      @Path("id") String id, @Body() Map<String, dynamic> payload);
}
