import 'package:flutter/material.dart';

class LargeTextAreaField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  LargeTextAreaField({
    required this.label,
    required this.controller,
    required String? Function(dynamic value) validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        minLines: 5,
        maxLines: 10,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label الحقل مطلوب ';
          }
          return null;
        },
      ),
    );
  }
}
