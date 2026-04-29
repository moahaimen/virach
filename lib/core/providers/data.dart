import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:racheeta/core/services/api_client.dart';
import 'package:racheeta/core/models/posts_model.dart';

class ProviderTesing extends ChangeNotifier {
  List<PostsModel> data = [];
  bool data_come = false;
  Future<List<PostsModel>> getAllData() async {
    data = [];
    data_come = false;
    final client = ApiClient(Dio(BaseOptions(contentType: "application/json")));
    data = await client.getUsers();
    data_come = true;
    notifyListeners();
    return data;
  }
}
