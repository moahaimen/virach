import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:racheeta/features/doctors/screens/patient_history_screen.dart';

import '../reservations/models/reservation_model.dart';
import '../reservations/providers/reservations_provider.dart';

/// A single row showing one reservation
class HSPAppointmentRow extends StatefulWidget {
  final ReservationModel appointment;
  final Function(String) onStatusChange;
  final Function(ReservationModel) confirmStatusChange;

  const HSPAppointmentRow({
    Key? key,
    required this.appointment,
    required this.onStatusChange,
    required this.confirmStatusChange,
  }) : super(key: key);

  @override
  _HSPAppointmentRowState createState() => _HSPAppointmentRowState();
}

class _HSPAppointmentRowState extends State<HSPAppointmentRow> {
  @override
  Widget build(BuildContext context) {
    // If this reservation is CANCELLED, hide the row entirely.
    if (widget.appointment.status?.toUpperCase() == 'CANCELLED') {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: _navigateToPatientProfile,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              // 1) Patient name + creation date
              Expanded(flex: 3, child: _buildNameAndCreationDate()),
              // 2) Status pill with dropdown
              _buildStatusDropdown(context),
              // 3) Confirmed appointment date/time if applicable
              _buildConfirmedDateTime(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameAndCreationDate() {
    final appointment = widget.appointment;
    final patientName = appointment.patient?.fullName ?? 'لا يوجد اسم المريض';

    final creationDate = appointment.createDate != null
        ? DateTime.parse(appointment.createDate!)
        : null;
    final formattedCreationDate = creationDate != null
        ? DateFormat('dd MMMM', 'ar_IQ_traditional').format(creationDate)
        : 'لا يوجد تاريخ';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          patientName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          formattedCreationDate,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    final statuses = ['CONFIRMED', 'PENDING', 'CANCELLED'];
    final currentStatus = widget.appointment.status?.toUpperCase() ?? 'PENDING';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: _getStatusColor(currentStatus),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStatus,
          icon: const SizedBox.shrink(), // hide default arrow
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          dropdownColor: Colors.white,
          items: statuses.map((status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Text(
                status,
                style: const TextStyle(color: Colors.black),
              ),
            );
          }).toList(),
          selectedItemBuilder: (_) {
            return statuses.map((status) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_drop_down,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 2),
                  Text(status, style: const TextStyle(color: Colors.white)),
                ],
              );
            }).toList();
          },
          onChanged: (newStatus) => _handleStatusChange(context, newStatus),
        ),
      ),
    );
  }

  Widget _buildConfirmedDateTime() {
    final app = widget.appointment;
    if (app.status == 'CONFIRMED' &&
        app.appointmentDate != null &&
        app.appointmentTime != null) {
      final appointmentDate = DateTime.parse(app.appointmentDate!);
      final dayMonth =
          DateFormat('dd MMMM', 'ar_IQ_traditional').format(appointmentDate);
      final timeStr = app.appointmentTime!;

      return Expanded(
        flex: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              dayMonth,
              style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
            Text(
              timeStr,
              style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      );
    }
    return const Expanded(flex: 2, child: SizedBox());
  }

  /// Called when the dropdown changes status (pending, confirmed, cancelled).
  Future<void> _handleStatusChange(
      BuildContext context, String? newStatus) async {
    if (newStatus == null) return;
    try {
      final provider = Provider.of<ReservationRetroDisplayGetProvider>(context,
          listen: false);

      if (newStatus == 'CONFIRMED') {
        final selectedDateTime = await _pickDateTime(context);
        if (selectedDateTime != null) {
          // Call your provider to update status in backend
          await provider.updateReservationStatusdashboard(
            context: context,
            reservationId: widget.appointment.id!,
            newStatus: 'CONFIRMED',
            pickedDateTime: selectedDateTime,
          );

          // Update local
          setState(() {
            widget.appointment.status = 'CONFIRMED';
            widget.appointment.appointmentDate =
                DateFormat('yyyy-MM-dd').format(selectedDateTime);
            widget.appointment.appointmentTime =
                DateFormat('HH:mm:ss').format(selectedDateTime);
          });
        }
      } else {
        // CANCELLED or PENDING
        await provider.updateReservationStatusdashboard(
          context: context,
          reservationId: widget.appointment.id!,
          newStatus: newStatus,
          pickedDateTime: DateTime.now(),
        );
        // If CANCELLED, it's removed from UI by the provider
        if (newStatus.toUpperCase() != 'CANCELLED') {
          setState(() {
            widget.appointment.status = newStatus;
            widget.appointment.appointmentDate = null;
            widget.appointment.appointmentTime = null;
          });
        }
      }
    } catch (e) {
      debugPrint("Error updating reservation: $e");
    }
  }

  void _navigateToPatientProfile() {
    if (widget.appointment.patient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("بيانات المريض غير متوفرة")),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientHistoryandProfilePage(
          reservationId: widget.appointment.id!,
        ),
      ),
    );
  }

  Future<DateTime?> _pickDateTime(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate == null) return null;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return null;

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return Colors.green.shade400;
      case 'PENDING':
        return Colors.orange.shade400;
      case 'CANCELLED':
        return Colors.red.shade400;
      default:
        return Colors.grey.shade400;
    }
  }
}
