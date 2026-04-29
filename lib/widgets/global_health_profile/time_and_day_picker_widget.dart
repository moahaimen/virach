import 'package:flutter/material.dart';

class TimeAndDayPicker extends StatefulWidget {
  final List<String> availableTimes;
  final List<String> availableDays;
  final Function(String, String, List<String>) onSave;

  const TimeAndDayPicker({
    required this.availableTimes,
    required this.availableDays,
    required this.onSave,
    Key? key,
  }) : super(key: key);

  @override
  _TimeAndDayPickerState createState() => _TimeAndDayPickerState();
}

class _TimeAndDayPickerState extends State<TimeAndDayPicker> {
  String selectedStartTime = '03:00 مساء';
  String selectedEndTime = '11:00 مساء';
  List<String> selectedDays = [];

  void _notifyParent() {
    // Immediately notify parent of the changes
    widget.onSave(selectedStartTime, selectedEndTime, selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('اختر ساعات وأيام العمل', style: TextStyle(fontSize: 18)),
        ),
        // Time Selection
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Start Time
            Column(
              children: [
                const Text('من:'),
                DropdownButton<String>(
                  value: selectedStartTime,
                  items: widget.availableTimes.map((time) {
                    return DropdownMenuItem<String>(
                      value: time,
                      child: Text(time),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() => selectedStartTime = newValue!);
                    _notifyParent();
                  },
                ),
              ],
            ),
            // End Time
            Column(
              children: [
                const Text('إلى:'),
                DropdownButton<String>(
                  value: selectedEndTime,
                  items: widget.availableTimes.map((time) {
                    return DropdownMenuItem<String>(
                      value: time,
                      child: Text(time),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() => selectedEndTime = newValue!);
                    _notifyParent();
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Day Selection
        const Text('اختر أيام العمل:', style: TextStyle(fontSize: 18)),
        Wrap(
          spacing: 10.0,
          children: widget.availableDays.map((day) {
            bool isSelected = selectedDays.contains(day);
            return ChoiceChip(
              label: Text(day),
              selected: isSelected,
              selectedColor: Colors.blue,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedDays.add(day);
                  } else {
                    selectedDays.remove(day);
                  }
                });
                _notifyParent();
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
