import 'package:flutter/material.dart';
import 'package:racheeta/models/header_section_list.dart';

class DetailPage extends StatelessWidget {
  final String serviceType;

  DetailPage({required this.serviceType});

  @override
  Widget build(BuildContext context) {
    final details = serviceDetails[serviceType] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(serviceType)),
      body: ListView.builder(
        itemCount: details.length,
        itemBuilder: (ctx, index) {
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: ListTile(
              title: Text(details[index]['title']!),
              subtitle: Text(details[index]['description']!),
            ),
          );
        },
      ),
    );
  }
}
