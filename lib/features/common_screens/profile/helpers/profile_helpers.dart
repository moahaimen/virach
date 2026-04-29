import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';

class ProfileHelpers {
  static Future<Map<String, dynamic>> fetchMeData({
    required String prefsKey,
    required String endpointUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("Login_access_token") ?? '';
    if (token.isEmpty) throw Exception("No token found");

    final dio = Dio();
    dio.options.headers["Authorization"] = "JWT $token";
    final response = await dio.get(endpointUrl);

    if (response.statusCode == 200 && response.data != null) {
      await prefs.setString(prefsKey, json.encode(response.data));
      return response.data;
    } else {
      throw Exception("Failed to fetch /me/ data: ${response.statusCode}");
    }
  }

  static LatLng? parseGps(String? gpsString) {
    if (gpsString == null || !gpsString.contains(',')) return null;
    final parts = gpsString.split(',');
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  static String? buildFullImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty || rawUrl.toLowerCase() == "null") {
      return null;
    }
    return rawUrl.startsWith("http")
        ? rawUrl
        : "https://racheeta.pythonanywhere.com$rawUrl";
  }
}
