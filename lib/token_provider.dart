import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenProvider with ChangeNotifier {
  String? _accessToken;

  String? get accessToken => _accessToken;

  void updateToken(String newToken) {
    _accessToken = newToken;
    notifyListeners();
  }

  Future<void> loadTokenFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString("access_token") ?? prefs.getString("Login_access_token");
    notifyListeners();
  }
}
