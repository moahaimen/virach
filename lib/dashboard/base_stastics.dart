import 'package:flutter/material.dart';
import '../constansts/constants.dart';
import '../features/doctors/widgets/dashboard_widgets/stastics_widgets.dart';

abstract class BaseStatistics extends StatelessWidget {
  // This method will be overridden by the subclasses to fetch statistics data
  List<Map<String, dynamic>> fetchStatisticsData();

  @override
  Widget build(BuildContext context) {
    final statsData = fetchStatisticsData();

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
              const Text(
                'احصائيات',
                style: kDashboardTitlesTextStyle,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: statsData.map((stat) {
                  return Expanded(
                    child: StatCard(
                        title: stat['title'],
                        value: stat['value'],
                        color: stat['color'],
                        icon: stat['icon']),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
