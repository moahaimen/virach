import 'package:flutter/material.dart';

class HeaderOptionProvider extends ChangeNotifier {
  String? selectedService;

  void selectService(String service) {
    selectedService = service;
    notifyListeners();
  }
}
