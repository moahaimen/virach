import 'package:flutter/material.dart';

import '../../../dashboard/base_stastics.dart';

class HospitalStatistics extends BaseStatistics {
  @override
  List<Map<String, dynamic>> fetchStatisticsData() {
    // Fetch nurse-specific statistics from an API or other source
    return [
      {
        'title': 'العدد  الكلي',
        'value': '150',
        'color': Colors.purple,
        'icon': Icons.person
      },
      {
        'title': 'الزيارات المنزلية ',
        'value': '10',
        'color': Colors.orange,
        'icon': Icons.home
      },
      {
        'title': 'حجوزات',
        'value': '20',
        'color': Colors.pink,
        'icon': Icons.event
      },
    ];
  }
}
