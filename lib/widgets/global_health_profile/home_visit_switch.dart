import 'package:flutter/material.dart';

class HomeVisitSwitch extends StatelessWidget {
  final bool homeVisit;
  final Function(bool) onToggle;

  const HomeVisitSwitch({required this.homeVisit, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('تستطيع عمل زيارات منزلية'),
      value: homeVisit,
      onChanged: (value) => onToggle(value),
    );
  }
}
