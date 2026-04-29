import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback? onTap;
  final TextInputType? keyboardType; // Add keyboardType parameter
  final String? Function(String?)? validator; // Add validator parameter

  DatePickerField({
    required this.label,
    required this.controller,
    this.onTap,
    this.keyboardType, // Initialize keyboardType
    this.validator, // Initialize validator
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        readOnly: true,
        keyboardType: keyboardType ?? TextInputType.datetime, // Default type
        validator: validator, // Use provided validator
        onTap: onTap ??
            () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
              }
            },
      ),
    );
  }
}
