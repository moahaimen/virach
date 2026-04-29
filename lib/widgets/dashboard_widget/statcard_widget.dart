import 'package:flutter/material.dart';

import '../../constansts/constants.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  StatCard(
      {required this.title,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(value, style: kHeaderTextStyle.copyWith(color: Colors.white)),
        Text(title, style: TextStyle(color: Colors.white)),
      ],
    );
  }
}
