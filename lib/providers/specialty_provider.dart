// specialty_provider.dart
import 'package:flutter/material.dart';

class SpecialtyProvider with ChangeNotifier {
  String? _selectedSpecialty;

  String? get selectedSpecialty => _selectedSpecialty;

  void setSpecialty(String specialty) {
    _selectedSpecialty = specialty;
    notifyListeners(); // Notify any listeners of the change
  }
}
