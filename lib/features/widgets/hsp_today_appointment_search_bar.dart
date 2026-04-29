import 'package:flutter/material.dart';

class HspTodayAppointmentSearchBar extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;

  const HspTodayAppointmentSearchBar({Key? key, required this.onSearchChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Search by Patient Name',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: onSearchChanged,
      ),
    );
  }
}
