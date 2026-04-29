import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../reservations/providers/reservations_provider.dart';
import '../../../../constansts/constants.dart';

class Stastics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final reservationProvider = Provider.of<ReservationRetroDisplayGetProvider>(context);
    final allReservations = reservationProvider.fullReservations;

    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final totalCount = allReservations.length;
    final todayCount = allReservations.where((r) => r.appointmentDate == todayStr).length;
    final upcomingCount = allReservations.where((r) {
      if (r.appointmentDate == null) return false;
      final apptDate = DateTime.tryParse(r.appointmentDate!);
      return apptDate != null && apptDate.isAfter(today);
    }).length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Doctor Stats', style: kDashboardTitlesTextStyle),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StatCard(
                      title: 'عدد المراجعين الكلي',
                      value: totalCount.toString(),
                      color: Colors.blue,
                      icon: Icons.person),
                  StatCard(
                      title: 'حجوزات اليوم',
                      value: todayCount.toString(),
                      color: Colors.green,
                      icon: Icons.person),
                  StatCard(
                      title: 'الحجوزات القادمة',
                      value: upcomingCount.toString(),
                      color: Colors.red,
                      icon: Icons.person),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(value, style: kStatsDashboardTextStyle),
        Text(title, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
