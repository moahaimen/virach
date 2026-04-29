import 'package:flutter/material.dart';

class DoctorsSearchBar extends StatelessWidget {
  final TextEditingController searchController;

  DoctorsSearchBar({required this.searchController});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: 'ابحث بالتخصص, اسم الدكتور, أو المستشفى',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
