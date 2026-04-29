import 'package:flutter/material.dart';
import 'package:racheeta/features/common_screens/signup_login/health_service_registration/city_district_selection_page.dart';
import '../../../../widgets/global_health_profile/gender_toggle_widget.dart';

class TherapistFields extends StatefulWidget {
  final GlobalKey<FormState>? formKey; // optional if you want a Form

  const TherapistFields({
    Key? key,
    this.formKey,
  }) : super(key: key);

  @override
  TherapistFieldsState createState() => TherapistFieldsState();
}

class TherapistFieldsState extends State<TherapistFields> {
  final TextEditingController bioController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String selectedSpecialty = "";
  String selectedDegree = "";

  // Getters for accessing field values
  String get bio => bioController.text;
  String get specialty => selectedSpecialty;
  String get degree => selectedDegree;
  String selectedCity = "بغداد";
  String selectedDistrict = "الأعظمية";
  int selectedGender = 0; // 0 => 'm', 1 => 'f'

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: widget.formKey, // optional if you want to validate
      child: Column(
        children: [
          // Dropdown for Specialty
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'التخصص',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(child: Text('علاج طبيعي'), value: 'physical'),
              DropdownMenuItem(child: Text('اخرى'), value: 'other'),
            ],
            onChanged: (newValue) {
              setState(() => selectedSpecialty = newValue ?? "");
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "اختر التخصص";
              }
              return null;
            },
          ),
          const SizedBox(height: 8),

          // Dropdown for Degree
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'الشهادة',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(child: Text('اعدادية'), value: 'Bacloria'),
              DropdownMenuItem(child: Text('دبلوم'), value: 'Diploma'),
              DropdownMenuItem(child: Text('بكلريوس'), value: 'BSC'),
              DropdownMenuItem(child: Text('ماستر'), value: 'Master'),
              DropdownMenuItem(child: Text('دكتوراة'), value: 'PHD'),
            ],
            onChanged: (newValue) {
              setState(() => selectedDegree = newValue ?? "");
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "اختر الشهادة";
              }
              return null;
            },
          ),
          const SizedBox(height: 8),

          // Bio Text Area
          TextFormField(
            controller: bioController,
            decoration: const InputDecoration(
              labelText: 'Bio',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "أدخل Bio";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Address Selection
          CityDistrictSelection(
            selectedCity: selectedCity,
            selectedDistrict: selectedDistrict,
            onCityChanged: (newCity) {
              setState(() => selectedCity = newCity);
            },
            onDistrictChanged: (newDistrict) {
              setState(() => selectedDistrict = newDistrict);
            },
          ),
          const SizedBox(height: 20),

          GenderToggleWidget(
            selectedGender: selectedGender,
            onToggle: (index) {
              setState(() => selectedGender = index);
            },
          ),
          if (selectedGender == 0)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "يرجى اختيار الجنس",
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    bioController.dispose();
    addressController.dispose();
    super.dispose();
  }
}

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
