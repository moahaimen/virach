import 'package:flutter/material.dart';

class GeneralSortBottomSheet extends StatelessWidget {
  final Function(String) onSort;
  final String sortTitle;

  GeneralSortBottomSheet({required this.onSort, required this.sortTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.5,
      child: ListView(
        children: [
          Center(
            child: Text(
              sortTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('الاسم من أ-ي'),
            onTap: () {
              onSort('name_asc');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('الاسم ي-أ'),
            onTap: () {
              onSort('name_desc');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('التخصص'),
            onTap: () {
              onSort('specialty');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('الشهادة'),
            onTap: () {
              onSort('degree');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('العنوان'),
            onTap: () {
              onSort('address');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
