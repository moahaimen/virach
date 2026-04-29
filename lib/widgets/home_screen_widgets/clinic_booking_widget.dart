import 'package:flutter/material.dart';

import 'package:dio/dio.dart';

class ClinicBookingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController _searchController = TextEditingController();

    Future<void> _search(String query) async {
      try {
        final response = await Dio().get(
          'https://racheeta.pythonanywhere.com/doctor/',
          queryParameters: {'query': query},
        );
        print('Search results: ${response.data}');
        // Handle search results
      } catch (e) {
        print('Error searching: $e');
        // Handle errors
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ابحث بالتخصص، اسم الدكتور، أو المستشفى',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                _search(_searchController.text);
              }
            },
          ),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            _search(value);
          }
        },
      ),
    );
  }
}
