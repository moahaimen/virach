import 'package:flutter/material.dart';

Widget buildEditableTile({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
  required TextEditingController controller,
  required bool enabled,
  FormFieldValidator<String>? validator, // No changes needed
}) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color),
    ),
    title: TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: subtitle,
        hintStyle: const TextStyle(color: Colors.grey),
      ),
    ),
    subtitle: Text(
      subtitle,
      style: const TextStyle(
        color: Colors.blue,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
