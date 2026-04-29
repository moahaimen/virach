import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import your own custom widgets
import '../../../../widgets/global_health_profile/custom_dropdown_widget.dart';
import '../../../../widgets/global_health_profile/custom_textformfield_widget.dart';

class DoctorFields extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const DoctorFields({Key? key, required this.formKey}) : super(key: key);

  @override
  DoctorFieldsState createState() => DoctorFieldsState();
}

class DoctorFieldsState extends State<DoctorFields> {
  // Controllers
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Dropdown lists
  final List<String> _degrees = [
    "بكلريوس",
    "ماستر",
    "دكتوراة",
    "بورد",
  ];

  final List<String> _specialties = [
    "اشعة وسونار",
    "باطنية",
    "امراض دم",
    "اورام",
    "انف واذن وحنجرة",
    "تغذية",
    "جلدية",
    "المجاري البولية",
    "تجميل",
    "عقم",
    "نسائية",
    "جراحة عامة",
    "أطفال",
    "أورام",
    "مفاصل",
    "قلبية",
    "مخ واعصاب",
    "طب نفسي",
    "بيطري",
    "الطب العام",
    "الجراحة العامة",
    "أمراض القلب",
    "الأمراض الباطنية",
    "طب الأطفال",
    "النسائية والتوليد",
    "التخدير",
    "الأورام",
    "جراحة المسالك البولية",
    "اسنان",
    "طب الأسرة",
    "الطب النفسي",
    "طب الطوارئ",
    "أمراض الكلى",
    "الغدد الصماء",
    "أمراض الدم",
    "الطب الرياضي",
    "العلاج الطبيعي",
  ];

  final List<Map<String, String>> _countries = [
    {'name': 'Iraq', 'flag': '🇮🇶'}, // Added Iraq to match initial value
    {'name': 'France', 'flag': '🇫🇷'},
    {'name': 'England', 'flag': '🇬🇧'},
    {'name': 'Germany', 'flag': '🇩🇪'},
    {'name': 'United States', 'flag': '🇺🇸'},
    {'name': 'Canada', 'flag': '🇨🇦'},
  ];

  String? selectedSpecialty;
  String? selectedDegree;
  String? selectedCountry = 'Iraq'; // Now exists in the list

  // Validation methods

  bool validateForm() {
    return widget.formKey.currentState?.validate() ?? false;
  }

  String? validateName(String? value) {
    print(">>> [DEBUG] validateName got: '$value', length=${value?.length}");

    if (value == null || value.isEmpty) {
      return "اسم الطبيب مطلوب";
    }
    if (value.length < 3) {
      return "اسم الطبيب يجب أن يكون أطول من حرفين";
    }
    return null;
  }

  String? validateSpecialty(String? value) {
    print(">>> [DEBUG] validateDegree got: '$value'");

    if (value == null || value.isEmpty) {
      return "التخصص مطلوب";
    }
    return null;
  }

  String? validateDegree(String? value) {
    print(">>> [DEBUG] validateDegree got: '$value'");

    if (value == null || value.isEmpty) {
      return "الشهادة مطلوبة";
    }
    return null;
  }

  String? validateBio(String? value) {
    print(">>> [DEBUG] validateBio got: '$value', length=${value?.length}");
    if (value == null || value.isEmpty) {
      return "السيرة الذاتية مطلوبة";
    }
    if (value.length < 10) {
      return "السيرة الذاتية يجب أن تكون أطول من 10 أحرف";
    }
    return null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) return null;

    // Check if input is a valid number (e.g., 250000 or 250000.5)
    final price = double.tryParse(value);
    if (price == null) {
      return "يرجى إدخال سعر صالح (أرقام فقط، مثل 250000 أو 250000.5)";
    }

    if (price <= 0) {
      return "السعر يجب أن يكون أكبر من صفر";
    }

    return null;
  }

  /// Getters so parent can access typed values
  // String get name => nameController.text.trim();
  String get bio => _bioController.text.trim();
  String get price => _priceController.text.trim();
  // String get phone => phoneController.text.trim();
  String? get specialty => selectedSpecialty;
  String? get degree => selectedDegree;
  String? get country => selectedCountry;

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: widget.formKey,
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Specialty Dropdown
          CustomDropdown(
            label: "التخصص",
            value: selectedSpecialty,
            items: _specialties,
            onChanged: (value) {
              setState(() {
                selectedSpecialty = value;
              });
              print(">>> [DEBUG] selectedSpecialty = $selectedSpecialty");
            },
            validator: validateSpecialty,
          ),
          const SizedBox(height: 8),

          // Degree Dropdown
          CustomDropdown(
            label: "الشهادات",
            value: selectedDegree,
            items: _degrees,
            onChanged: (value) {
              setState(() {
                selectedDegree = value;
              });
              print(">>> [DEBUG] Degrees changed to: $selectedDegree");
            },
            validator: validateDegree,
          ),
          const SizedBox(height: 8),

          // Bio
          CustomTextFormFieldWidget(
            hint: 'السيرة الذاتية',
            label: 'السيرة الذاتية',
            controller: _bioController,
            validator: validateBio,
            minLines: 3, // Starts with 1 line
            maxLines: null, // No maximum lines
          ),
          CustomTextFormFieldWidget(
            hint: 'سعر الكشفية -الاجابة اختيارية',
            label: 'سعر الكشفية -الاجابة اختيارية',
            controller: _priceController,
            keyboardType: TextInputType.numberWithOptions(
                decimal: true), // Show numeric keyboard
            inputFormatters: [
              // Allow digits (0-9) and a single decimal point
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
              // Block multiple decimal points (e.g., "250.000.5")
              TextInputFormatter.withFunction((oldValue, newValue) {
                final text = newValue.text;
                if (text.split('.').length > 2) {
                  return oldValue; // Reject invalid input
                }
                return newValue;
              }),
            ],
            validator: validatePrice,
          ),
          const SizedBox(height: 8),

          // Phone Number
          const SizedBox(height: 16),

          // Country Dropdown
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'الدولة:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedCountry,
                  items: _countries
                      .map((country) => DropdownMenuItem(
                            value: country['name'],
                            child: Row(
                              children: [
                                Text(country['flag']!),
                                const SizedBox(width: 8),
                                Text(country['name']!),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (newValue) {
                    setState(() => selectedCountry = newValue);
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'الدولة',
                  ),
                  validator: (value) {
                    if (value == null)
                      return 'يرجى اختيار الدولة'; // Arabic error message
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }
}
