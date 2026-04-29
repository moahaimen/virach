import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  // Initialize with a default JWT token
  String? _jwtToken =
      "JWT eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzM0ODkyNzk4LCJpYXQiOjE3MzQ4ODkxOTgsImp0aSI6ImRlMjk2YjY3M2E3NzQ2ZDU4Njk5OTVhNDQ1YzVmNDIxIiwidXNlcl9pZCI6IjJlZjYyODEwLTIwYjQtNDExZi05OTY2LTExNGU0ZTBjYzdiZSJ9.q7qF38QfhZhqHgCXBY0lrhci1gSvJpeWOohCExJM_10";

  String? get jwtToken => _jwtToken;

  // Set a new JWT token
  void setToken(String token) {
    _jwtToken = token;
    notifyListeners();
  }

  // Clear the JWT token
  void clearToken() {
    _jwtToken = null;
    notifyListeners();
  }
}
