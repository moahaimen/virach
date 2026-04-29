import 'package:flutter/material.dart';

class DiscountDropdown extends StatelessWidget {
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  DiscountDropdown({
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: const InputDecoration(
          labelText: 'الخصم',
          border: OutlineInputBorder(),
        ),
        items: ['10%', '25%', '50%'].map((String discount) {
          return DropdownMenuItem<String>(
            value: discount,
            child: Text(discount),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null) {
            return 'يرجى اختيار الخصم';
          }
          return null;
        },
      ),
    );
  }
}
