import 'package:flutter/material.dart';

class AppointmentRow extends StatefulWidget {
  final Map<String, dynamic> appointment;

  AppointmentRow({required this.appointment});

  @override
  _AppointmentRowState createState() => _AppointmentRowState();
}

class _AppointmentRowState extends State<AppointmentRow> {
  late String _status;

  // Mapping between status values and their translations
  final Map<String, String> statusTranslations = {
    'Confirmed': 'مقبول',
    'Pending': 'معلق',
    'Cancelled': 'ملغى',
  };

  // Reverse mapping for updating the status
  final Map<String, String> reverseStatusTranslations = {
    'مقبول': 'Confirmed',
    'معلق': 'Pending',
    'ملغى': 'Cancelled',
  };

  @override
  void initState() {
    super.initState();
    _status = widget.appointment['status']; // Initialize the status
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(widget.appointment['patientName'])),
          SizedBox(width: 5),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.appointment['date']),
                Text(widget.appointment['time']),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: _getStatusColor(_status), // Color depends on the status
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value:
                    statusTranslations[_status], // Translate status to Arabic
                items: statusTranslations.values.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(
                      status,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                onChanged: (newStatus) {
                  setState(() {
                    _status = reverseStatusTranslations[newStatus!]!;
                    widget.appointment['status'] =
                        _status; // Update the appointment status
                  });
                },
                underline: Container(),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                dropdownColor: _getStatusColor(_status), // Dropdown color
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Icon(Icons.message, color: Colors.blue, size: 16),
              ],
            ),
          ),
          const Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit, color: Colors.grey, size: 16),
                SizedBox(width: 8),
                Icon(Icons.delete, color: Colors.red, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
