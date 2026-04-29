import 'package:flutter/material.dart';
import 'package:racheeta/constansts/constants.dart';

import '../model/filter_manager_model.dart';
import '../widgets/filter_checkboxes_section_widget.dart';

class HspFilterPage extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  HspFilterPage({required this.currentFilters, required this.onApplyFilters});

  @override
  _HspFilterPageState createState() => _HspFilterPageState();
}

class _HspFilterPageState extends State<HspFilterPage> {
  late FilterManager filterManager;

  @override
  void initState() {
    super.initState();
    filterManager = FilterManager(Map.from(widget.currentFilters));
  }

  void _applyFilters() {
    widget.onApplyFilters(filterManager.filters);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تصفية الخدمات الطبية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _applyFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          FilterSectionWidget(
            title: 'نوع الخدمة',
            options: ['دكتور', 'دكتورة'],
            filterKeys: ['sex_male', 'sex_female'],
            filterManager: filterManager,
          ),
          FilterSectionWidget(
            title: 'الدرجة العلمية',
            options: ['استشاري', 'اختصاص'],
            filterKeys: ['degree_consultant', 'degree_specialist'],
            filterManager: filterManager,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: kRedElevatedButtonStyle,
              onPressed: _applyFilters,
              child: const Text('ابحث', style: kDoctorSearchTextStyle),
            ),
          ),
        ],
      ),
    );
  }
}
