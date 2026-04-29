import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenProvider with ChangeNotifier {
  String? _accessToken;

  String? get accessToken => _accessToken;

  void updateToken(String newToken) {
    _accessToken = newToken;
    notifyListeners();
    print("Access token updated: $_accessToken");
    print("===============================");
    print("Access token from TOKEN PROVIDER: $_accessToken");
    print("===============================");
  }

  Future<void> loadTokenFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString("Login_access_token");
    print("===============================");
    print(
        "Access token from TOKEN PROVIDER in loadTokenFromPreferences: $_accessToken");
    print("===============================");
    notifyListeners();
  }
}
