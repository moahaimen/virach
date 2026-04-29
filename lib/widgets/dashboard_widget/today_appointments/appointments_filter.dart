import 'package:flutter/material.dart';

class AppointmentsFilter extends StatefulWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  AppointmentsFilter({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  _AppointmentsFilterState createState() => _AppointmentsFilterState();
}

class _AppointmentsFilterState extends State<AppointmentsFilter> {
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();

    // Ensure that the _selectedFilter is never null
    _selectedFilter = widget.selectedFilter.isNotEmpty
        ? widget.selectedFilter
        : 'All'; // Default to 'All' if widget.selectedFilter is empty or null
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          ':فلترة عن طريق الحالة  ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        DropdownButton<String>(
          value: _selectedFilter,
          items: ['All', 'Confirmed', 'Pending', 'Cancelled']
              .map((String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ))
              .toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedFilter = newValue;
                widget.onFilterChanged(newValue); // Notify the parent widget
              });
            }
          },
        ),
      ],
    );
  }
}
