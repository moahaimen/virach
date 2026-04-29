import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/api_client.dart';
import '../models/login_model.dart';

class LoginProvider extends ChangeNotifier {
  bool data_come = false;
  Future<LoginResponse> login(String email, String password) async {
    data_come = false;
    final client = ApiClient(Dio(BaseOptions(contentType: "application/json")));
    LoginResponse Response_login =
        await client.login({"email": email, "password": password});
    print(Response_login.access);
    data_come = true;
    notifyListeners();
    return Response_login;
  }
}
