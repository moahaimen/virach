import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import '../models/offers_model.dart';

class OffersRetroDisplayGetProvider with ChangeNotifier {
  late ApiClient _apiClient;
  List<OffersModel> offers = [];
  late final Dio _dio;                   // if not already defined

  OffersRetroDisplayGetProvider(String token) {
    _dio = Dio();
    setAuthToken(token);                 // initialise header
    _apiClient = ApiClient(_dio);
  }

  /// keep token in sync with TokenProvider
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'JWT $token';
  }

  /// Get all offers
// provider
  Future<void> getOffers({bool forPatient = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // accept either key; take whichever is non-null first
      final String token  =
          prefs.getString('token') ?? prefs.getString('access_token') ?? '';

      final String userId = prefs.getString('user_id') ?? '';
      final String role   = prefs.getString('role')   ?? '';

      final dio = Dio();
      if (token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'JWT $token';
      }

      _apiClient = ApiClient(dio);

      offers = (role == 'patient' || forPatient)
          ? await _apiClient.getOffers()                      // all offers
          : await _apiClient.getOffersbyServiceProviderID(userId);

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching offers: $e');
    }
  }

  /// Create a new offer
  Future<OffersModel?> createOffer(FormData offerData) async {
    try {
      print(">>> [Provider] Starting offer creation...");
      print(">>> [Provider] Offer Data: $offerData");

      // Call Retrofit's createOffer
      final offer = await _apiClient.createOffer(offerData);

      // Debugging print for the created offer
      print(">>> [Provider] Offer Created Successfully: ${offer.toJson()}");

      offers.add(offer);
      notifyListeners();

      return offer;
    } catch (e) {
      print(">>> [Provider] Error creating offer: $e");

      if (e is DioError) {
        print(">>> [Provider] DioError Details:");
        print("    Request Data: ${e.requestOptions.data}");
        print("    Response Data: ${e.response?.data}");
        print("    Status Code: ${e.response?.statusCode}");
      }

      return null;
    }
  }

  /// Update an offer
  Future<OffersModel?> updateOffer(String id, FormData offerData) async {
    try {
      print(">>> [UPDATE] Starting update for offer ID: $id");

      // Log all standard fields
      print(">>> [UPDATE] FormData fields:");
      for (var field in offerData.fields) {
        print("    ${field.key}: ${field.value}");
      }

      // Check for image presence safely
      final hasImage = offerData.files.any((f) => f.key == 'offer_image');
      print(">>> [UPDATE] Image field: ${hasImage ? 'Present' : 'Not included'}");

      // Send update request
      final updatedOffer = await _apiClient.updateOffer(id, offerData);
      print(">>> [UPDATE] Server response: ${updatedOffer.toJson()}");

      // Update local state
      final index = offers.indexWhere((offer) => offer.id == id);
      if (index != -1) {
        offers[index] = updatedOffer;
        notifyListeners();
      }

      return updatedOffer;

    } catch (e) {
      print(">>> [UPDATE] Error updating offer: $e");

      if (e is DioError) {
        print(">>> [DIO ERROR]");
        print("    URI: ${e.requestOptions.uri}");
        print("    METHOD: ${e.requestOptions.method}");
        print("    HEADERS: ${e.requestOptions.headers}");
        print("    DATA SENT: ${e.requestOptions.data}");
        print("    STATUS CODE: ${e.response?.statusCode}");
        print("    RESPONSE BODY: ${e.response?.data}");
      }

      return null;
    }
  }


  /// Delete an offer
  Future<void> deleteOffer(String id) async {
    try {
      await _apiClient.deleteOffer(id);
      offers.removeWhere((offer) => offer.id == id);
      notifyListeners();
    } catch (e) {
      print("Error deleting offer: $e");
    }
  }

  /// Get offers by serviceProviderId:
  /// Fetches only the offers related to the given serviceProviderId.
  /// Includes debugging logs to identify failing fields.
  Future<void> getOffersForCurrentUser(String serviceProviderId) async {
    try {
      print(
          ">>> [DEBUG] Fetching offers for serviceProviderId: $serviceProviderId");

      final response =
      await _apiClient.getOffersbyServiceProviderID(serviceProviderId);

      // Debugging: Print the raw API response
      print(
          ">>> [DEBUG] Raw API Response: ${response.map((offer) => offer.toJson()).toList()}");

      offers = response;

      // Debugging: Print the number of offers received
      print(">>> [DEBUG] Total Offers Retrieved: ${offers.length}");

      // Debugging: Print the details of each offer (if available)
      if (offers.isNotEmpty) {
        for (int i = 0; i < offers.length; i++) {
          print(">>> [DEBUG] Offer #$i: ${offers[i].toJson()}");

          // Validate individual fields for issues
          _validateOfferFields(offers[i], i);
        }
      }

      notifyListeners();
    } catch (e) {
      print(">>> [ERROR] Error fetching offers for current user: $e");

      if (e is DioError) {
        print(">>> [ERROR] DioError Details:");
        print("    Request URL: ${e.requestOptions.uri}");
        print("    Request Headers: ${e.requestOptions.headers}");
        print("    Request Method: ${e.requestOptions.method}");
        print("    Request Data: ${e.requestOptions.data}");
        print("    Response Status Code: ${e.response?.statusCode}");
        print("    Response Data: ${e.response?.data}");
      }
    }
  }

  /// Validate fields in an offer model and pinpoint errors
  void _validateOfferFields(OffersModel offer, int index) {
    if (offer.id == null || offer.id!.isEmpty) {
      print(">>> [ERROR] Offer #$index: Missing 'id' field!");
    }
    if (offer.serviceProviderId == null || offer.serviceProviderId!.isEmpty) {
      print(">>> [ERROR] Offer #$index: Missing 'serviceProviderId' field!");
    }
    if (offer.offerTitle == null || offer.offerTitle!.isEmpty) {
      print(">>> [ERROR] Offer #$index: Missing 'offerTitle' field!");
    }
    if (offer.offerDescription == null || offer.offerDescription!.isEmpty) {
      print(">>> [ERROR] Offer #$index: Missing 'offerDescription' field!");
    }
    if (offer.originalPrice == null || offer.originalPrice!.isEmpty) {
      print(">>> [ERROR] Offer #$index: Missing 'originalPrice' field!");
    }
    if (offer.discountedPrice == null || offer.discountedPrice!.isEmpty) {
      print(">>> [ERROR] Offer #$index: Missing 'discountedPrice' field!");
    }
    if (offer.startDate == null || offer.startDate!.isEmpty) {
      print(">>> [ERROR] Offer #$index: Missing 'startDate' field!");
    }
    if (offer.endDate == null || offer.endDate!.isEmpty) {
      print(">>> [ERROR] Offer #$index: Missing 'endDate' field!");
    }
    if (offer.createUser == null || offer.createUser!.isEmpty) {
      print(">>> [ERROR] Offer #$index: Missing 'createUser' field!");
    }
  }
}
