import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../features/reservations/models/reservation_model.dart';

class HSPAppointmentRow extends StatefulWidget {
  final ReservationModel appointment;
  final String roleType; // e.g., "doctor", "nurse", "hospital"
  final Function(String) onStatusChange;
  final Function(ReservationModel) confirmStatusChange;

  const HSPAppointmentRow({
    Key? key,
    required this.appointment,
    required this.roleType,
    required this.onStatusChange,
    required this.confirmStatusChange,
  }) : super(key: key);

  @override
  _HSPAppointmentRowState createState() => _HSPAppointmentRowState();
}

class _HSPAppointmentRowState extends State<HSPAppointmentRow> {
  DateTime? selectedDateTime;

  @override
  Widget build(BuildContext context) {
    final String providerName =
        widget.appointment.patient?.fullName ?? 'No Provider Name';

    return InkWell(
      onTap: () {
        // Handle navigation or specific actions based on roleType
        if (widget.roleType == 'doctor' && widget.appointment.patient != null) {
          // Navigate to the doctor's specific page
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => SomeDoctorSpecificScreen(),
          //   ),
          // );
        }
        // Add conditions for other roleTypes (e.g., nurse, hospital)
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(providerName, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 5),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.appointment.createDate != null) ...[
                        Text(
                          DateFormat('yy-MM-dd').format(
                              DateTime.parse(widget.appointment.createDate!)),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold), // Display date
                        ),
                        Text(
                          DateFormat('hh:mm:ss a').format(
                              DateTime.parse(widget.appointment.createDate!)),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey), // Display time
                        ),
                      ] else
                        const Text(
                          'No Date',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.only(left: 0, right: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                          widget.appointment.status ?? 'PENDING'),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.centerLeft,
                    child: DropdownButton<String>(
                      value:
                          widget.appointment.status?.toUpperCase() ?? 'PENDING',
                      items: ['CONFIRMED', 'PENDING', 'CANCELLED']
                          .map((status) => DropdownMenuItem<String>(
                                value: status,
                                child: Text(
                                  status,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (newStatus) async {
                        if (newStatus != null) {
                          // Update the status based on selection
                          if (newStatus == 'CONFIRMED') {
                            final selectedDateTime =
                                await _pickDateTime(context);
                            if (selectedDateTime != null) {
                              setState(() {
                                widget.appointment.status = 'CONFIRMED';
                                widget.appointment.appointmentDate =
                                    DateFormat('yyyy-MM-dd')
                                        .format(selectedDateTime);
                                widget.appointment.appointmentTime =
                                    DateFormat('hh:mm:ss a')
                                        .format(selectedDateTime);
                              });
                            }
                          } else {
                            setState(() {
                              widget.appointment.status = newStatus;
                              widget.appointment.appointmentDate = null;
                              widget.appointment.appointmentTime = null;
                            });
                          }
                        }
                      },
                      underline: Container(),
                      icon: const Icon(Icons.arrow_drop_down),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _pickDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        return DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
    return null;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
