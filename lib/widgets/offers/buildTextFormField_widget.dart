import 'package:flutter/material.dart';

Widget buildTextFormField(
    String label, TextEditingController controller, bool isEnabled,
    {bool isNumber = false, int minLength = 10}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      controller: controller,
      enabled: isEnabled,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label الحقل مطلوب ';
        }
        if (isNumber && double.tryParse(value) == null) {
          return 'رجاء ادخل رقم مقبول $label';
        }
        if (value.length < minLength) {
          return '$label يجب ان يكون على الاقل $minLength حرف';
        }
        return null;
      },
    ),
  );
}
