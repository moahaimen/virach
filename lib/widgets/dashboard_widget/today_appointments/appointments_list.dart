import 'package:flutter/material.dart';
import 'appointment_row.dart'; // import the appointment row widget

class AppointmentList extends StatelessWidget {
  final List<Map<String, dynamic>> appointments;

  AppointmentList({required this.appointments});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeaderRow(), // Add the header row here
        Divider(color: Colors.grey),
        ...appointments.map((appointment) {
          return AppointmentRow(appointment: appointment);
        }).toList(),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              ' الاسم',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 5),
          Expanded(
            flex: 2,
            child: Text(
              'التاريخ والوقت',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'الحالة',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'اتصال',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'الاجراء',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
