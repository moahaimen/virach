import 'package:flutter/material.dart';

class HspTodayAppointmentFilterRow extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const HspTodayAppointmentFilterRow({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'تصفية بحالة الحجز: ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        DropdownButton<String>(
          value: selectedFilter,
          items:
              ['All', 'CONFIRMED', 'PENDING', 'CANCELLED'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onFilterChanged(newValue);
            }
          },
        ),
      ],
    );
  }
}
