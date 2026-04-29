import 'package:flutter/material.dart';

class TimeDayPicker extends StatelessWidget {
  final List<String> availableTimes = [
    '03:00 مساء',
    '04:00 مساء',
    '05:00 مساء',
    '06:00 مساء',
    '07:00 مساء',
    '08:00 مساء',
    '09:00 مساء',
    '10:00 مساء',
    '11:00 مساء',
  ];

  final List<String> availableDays = [
    'السبت',
    'الاحد',
    'الاثنين',
    'الثلاثاء',
    'الاربعاء',
    'الخميس',
    'الجمعة',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('اختر ساعات وأيام العمل', style: TextStyle(fontSize: 18)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropdownButton<String>(
              items: availableTimes.map((time) {
                return DropdownMenuItem<String>(
                  value: time,
                  child: Text(time),
                );
              }).toList(),
              onChanged: (newValue) {},
            ),
            DropdownButton<String>(
              items: availableTimes.map((time) {
                return DropdownMenuItem<String>(
                  value: time,
                  child: Text(time),
                );
              }).toList(),
              onChanged: (newValue) {},
            ),
          ],
        ),
        Wrap(
          spacing: 10.0,
          children: availableDays.map((day) {
            return ChoiceChip(
              label: Text(day),
              selected: false,
              onSelected: (selected) {},
            );
          }).toList(),
        ),
      ],
    );
  }
}
