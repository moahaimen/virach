import 'package:flutter/material.dart';

Widget buildLargeTextAreaField(String label, TextEditingController controller,
    {required String? Function(dynamic value) validator}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      controller: controller,
      maxLines: 6,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      },
    ),
  );
}
