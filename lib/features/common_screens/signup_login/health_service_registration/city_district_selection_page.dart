import 'package:flutter/material.dart';

class CityDistrictSelection extends StatefulWidget {
  final String selectedCity;
  final String selectedDistrict;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<String> onDistrictChanged;

  const CityDistrictSelection({
    Key? key,
    required this.selectedCity,
    required this.selectedDistrict,
    required this.onCityChanged,
    required this.onDistrictChanged,
  }) : super(key: key);

  @override
  _CityDistrictSelectionState createState() => _CityDistrictSelectionState();
}

class _CityDistrictSelectionState extends State<CityDistrictSelection> {
  final List<String> districts = [
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
    'الفرات ',
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: widget.selectedCity,
              items: ['بغداد'].map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(
                    city,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.onCityChanged(value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'المدينة',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: districts.contains(widget.selectedDistrict)
                  ? widget.selectedDistrict
                  : null,
              items: districts.map((district) {
                return DropdownMenuItem(
                  value: district,
                  child: Text(
                    district,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.onDistrictChanged(value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'الحي',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
