import 'package:flutter/material.dart';
import 'package:flutter/src/services/text_formatter.dart';

// Updated CustomTextFormFieldWidget to accept an external validator
class CustomTextFormFieldWidget extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isPhone;
  final int? maxLines; // Make maxLines nullable
  final int? minLines; // Add minLines (optional)
  final String? Function(String?)? validator; // Accepts an external validator
  final List<TextInputFormatter> inputFormatters;
  final TextInputType keyboardType;

  const CustomTextFormFieldWidget({
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines, // Default: null (auto-expand)
    this.minLines = 1, // Start with 1 line
    this.isPhone = false,
    this.validator,
    this.inputFormatters = const [], // Default empty list
    this.keyboardType = TextInputType.text, // Default text input
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        minLines: minLines, // Set minLines
        maxLines: maxLines, // Set to null for auto-expand
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: validator, // Uses the external validator
      ),
    );
  }
}
