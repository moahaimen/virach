import 'package:flutter/material.dart';

class SortingModal extends StatelessWidget {
  final Function onSort;

  SortingModal({required this.onSort});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'الترتيب',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('الأعلى تقييما'),
              onTap: () {
                onSort('highest_rating');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('الأقل تقييما'),
              onTap: () {
                onSort('lowest_rating');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('ترتيب أبجدي أ الى ي'),
              onTap: () {
                onSort('name_asc');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('ترتيب أبجدي ي الى أ'),
              onTap: () {
                onSort('name_desc');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:
                  const Text('مسح الكل', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
