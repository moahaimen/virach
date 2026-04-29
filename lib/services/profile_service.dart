// lib/services/profile_service.dart

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service that knows how to fetch the `/me/` endpoint and cache it locally.
///
/// All screens that need “load my profile” can call [ProfileService.fetchMeData()],
/// which returns the JSON map.  Each screen is then responsible for “assigning” its
/// own controllers or state from that map.
class ProfileService {
  /// Fetches `/me/` from the backend, returning the full JSON as a Map.
  ///
  /// It also stores the raw JSON string into SharedPreferences under
  /// key "beauty_center_profile_data" (you can rename this per‐screen if you like,
  /// or pass in your own prefsKey).
  static Future<Map<String, dynamic>> fetchMeData({
    required String prefsKey,
    required String endpointUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('Login_access_token');
    if (token == null || token.isEmpty) {
      throw Exception('No token found in SharedPreferences');
    }

    // Set the JWT header
    final dio = Dio()..options.headers['Authorization'] = 'JWT $token';

    final response = await dio.get(endpointUrl);
    if (response.statusCode == 200 && response.data != null) {
      // Cache the raw JSON string
      await prefs.setString(prefsKey, json.encode(response.data));
      return Map<String, dynamic>.from(response.data);
    } else {
      throw Exception('Failed to fetch /me/ (status: ${response.statusCode})');
    }
  }
}
