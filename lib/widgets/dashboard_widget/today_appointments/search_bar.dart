import 'package:flutter/material.dart';

class SearchyBar extends StatelessWidget {
  final Function(String) onSearch;

  SearchyBar({required this.onSearch}); // Fix the parameter name here

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
        onChanged: (value) {
          onSearch(value); // Use the callback here
        },
      ),
    );
  }
}
