import 'package:flutter/material.dart';
import 'package:racheeta/theme/app_theme.dart';
import '../features/doctors/widgets/dashboard_widgets/stastics_widgets.dart';

abstract class BaseStatistics extends StatelessWidget {
  const BaseStatistics({super.key});

  List<Map<String, dynamic>> fetchStatisticsData();

  @override
  Widget build(BuildContext context) {
    final statsData = fetchStatisticsData();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8, bottom: 12),
            child: Text(
              'نظرة عامة على الإحصائيات',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: RacheetaColors.textPrimary,
              ),
            ),
          ),
          Row(
            children: statsData.asMap().entries.map((entry) {
              final idx = entry.key;
              final stat = entry.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: idx == statsData.length - 1 ? 0 : 8,
                    right: idx == 0 ? 0 : 8,
                  ),
                  child: StatCard(
                    title: stat['title'],
                    value: stat['value'],
                    color: stat['color'],
                    icon: stat['icon'],
                    subtitle: stat['subtitle'],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
