import 'package:flutter/material.dart';

class CityDistrictSelector extends StatelessWidget {
  final String? city;
  final String? district;
  final bool enabled;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<String> onDistrictChanged;

  static const List<String> _districts = [
    'الأعظمية',
    'الأمين',
    '(حي أور)',
    'الإعلام (حي الإعلام)',
    'العامرية',
    'العبيدي',
    'العطيفية',
    'حي العدل',
    'باب المعظم',
    'البتاوين',
    'حي البنوك',
    'البياع',
    'البلديات',
    'بغداد الجديدة',
    'الجادرية',
    'حي الجهاد',
    'جميلة',
    'الحارثية',
    'حي الحسين',
    'الحرية',
    'حي العامل',
    'حي الجامعة',
    'حي حطين',
    'حي تونس',
    'حي جميلة',
    'الخضراء',
    'الدورة',
    'حي الرسالة',
    'زيونة',
    'سبع أبكار',
    'حي السلام',
    'السيدية',
    'الشعب',
    'الشرطة (حي الشرطة)',
    'شارع فلسطين',
    'مدينة الصدر',
    'الصليخ',
    'الطالبية',
    'الغدير',
    'الغزالية',
    'الفرات',
    'حي القاهرة',
    'القادسية',
    'الكاظمية',
    'الكرادة',
    'الكفاح',
    'المأمون (حي المأمون)',
    'المثنى (حي المثنى)',
    'المستنصرية (حي المستنصرية)',
    'المعالف',
    'المنصور',
    'المواصلات (حي المواصلات)',
    'الوزيرية',
    'الوشاش',
    'اليرموك',
  ];

  const CityDistrictSelector({
    Key? key,
    required this.city,
    required this.district,
    required this.enabled,
    required this.onCityChanged,
    required this.onDistrictChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Only one city (بغداد); ensure the value matches the items or is null
    final cityValue = (city != null && city == 'بغداد') ? city : null;
    // District value: ensure it’s in the _districts list
    final districtValue = (district != null && _districts.contains(district))
        ? district
        : null;

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            value: cityValue,
            decoration: const InputDecoration(
              labelText: 'المدينة',
              border: OutlineInputBorder(),
            ),
            items: const ['بغداد'].map((c) {
              return DropdownMenuItem(value: c, child: Text(c));
            }).toList(),
            onChanged: enabled ? (val) => onCityChanged(val!) : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<String>(
            value: districtValue,
            decoration: const InputDecoration(
              labelText: 'الحي',
              border: OutlineInputBorder(),
            ),
            items: _districts.map((d) {
              return DropdownMenuItem(value: d, child: Text(d));
            }).toList(),
            onChanged: enabled ? (val) => onDistrictChanged(val!) : null,
          ),
        ),
      ],
    );
  }
}
