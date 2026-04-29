import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/offers_model.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://racheeta.pythonanywhere.com/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;
// New method to create an offer
//   @POST("/offers/")
//   Future<OffersModel> createOffer(@Body() Map<String, dynamic> offerData);
  @POST("/offers/")
  Future<OffersModel> createOffer(@Body() dynamic offerData);

  @GET("/offers/")
  Future<List<OffersModel>> getOffers();

  @PATCH("/offers/{id}/")
  Future<OffersModel> updateOffer(
      @Path("id") String id,
      @Body() FormData offerData,   // ← was Map<String, dynamic>
      );

  @DELETE("/offers/{id}/")
  Future<void> deleteOffer(@Path("id") String id);

  /// If [serviceProviderId] is null, it fetches all; otherwise filters by that ID.
  @GET("/offers/")
  Future<List<OffersModel>> getOffersbyServiceProviderID(
      @Query("service_provider_id") String? serviceProviderId,
      );

}
