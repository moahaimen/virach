import 'package:flutter/material.dart';

Widget GeneralCustomTextFields({
  required String labelText,
  required TextEditingController controller,
  required String hintText,
  required String validatorText,
  bool isPhone = false,
  required Icon suffixIcon,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(labelText, style: TextStyle(fontSize: 16)),
      const SizedBox(height: 5),
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            hintText: hintText,
            border: InputBorder.none, // Remove border for shadow effect
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return validatorText;
            }
            return null;
          },
        ),
      ),
    ],
  );
}
