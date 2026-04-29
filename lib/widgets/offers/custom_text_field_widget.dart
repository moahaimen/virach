import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isNumber;
  final TextInputType keyboardType;
  final String? Function(dynamic value)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final Function(String)? onChanged; // <-- Add onChanged parameter

  CustomTextField({
    required this.label,
    required this.controller,
    this.isNumber = false,
    required this.keyboardType,
    this.validator,
    this.inputFormatters,
    this.readOnly = false,
    this.onChanged, // <-- Add onChanged to constructor
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        readOnly: readOnly,
        onChanged: onChanged, // <-- Apply onChanged
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }
}
