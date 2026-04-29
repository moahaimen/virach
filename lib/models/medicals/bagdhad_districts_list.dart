import 'package:flutter/material.dart';

// List of districts in Baghdad
final List<String> districts = [
  'الأعظمية',
  'الأمين',
  'الأور (حي أور)',
  'الإعلام (حي الإعلام)',
  'العامرية',
  'العبيدي',
  'العطيفية',
  'العدل (حي العدل)',
  'باب المعظم',
  'البتاوين',
  'البنوك (حي البنوك)',
  'البياع',
  'البلديات',
  'بغداد الجديدة',
  'الجادرية',
  'الجهاد (حي الجهاد)',
  'جميلة (حي جميلة)',
  'الحارثية',
  'الحسين (حي الحسين)',
  'الحرية',
  'حي العامل',
  'حي الجامعة',
  'حي حطين',
  'حي تونس',
  'حي جميلة',
  'الخضراء (حي الخضراء)',
  'الدورة',
  'الرسالة (حي الرسالة)',
  'زيونة',
  'سبع أبكار',
  'السلام (حي السلام)',
  'السيدية',
  'الشعب',
  'الشرطة (حي الشرطة)',
  'شارع فلسطين',
  'الصدر (مدينة الصدر)',
  'الصليخ',
  'الطالبية',
  'العامرية',
  'العبيدي',
  'العطيفية',
  'العدل',
  'الغدير',
  'الغزالية',
  'الفرات (حي الفرات)',
  'القاهرة (حي القاهرة)',
  'القادسية (حي القادسية)',
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

class AddressSelectionPage extends StatelessWidget {
  final List<String> districts;

  const AddressSelectionPage({Key? key, required this.districts})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر العنوان'),
      ),
      body: ListView.builder(
        itemCount: districts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(districts[index]),
            onTap: () {
              Navigator.pop(context, districts[index]);
            },
          );
        },
      ),
    );
  }
}
