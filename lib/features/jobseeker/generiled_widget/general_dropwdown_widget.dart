import 'package:flutter/material.dart';

// Helper method to build dropdown fields
Widget BuildDropdownField({
  required String label,
  required String? value,
  required List<String> items,
  required void Function(String?) onChanged,
  required String validatorMessage,
}) {
  return DropdownButtonFormField<String>(
    value: value,
    hint: Text('اختر $label'),
    items: items.map((item) {
      return DropdownMenuItem<String>(
        value: item,
        child: Text(item),
      );
    }).toList(),
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return validatorMessage;
      }
      return null;
    },
  );
}
