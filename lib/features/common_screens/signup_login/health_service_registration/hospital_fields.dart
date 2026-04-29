import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HospitalFields extends StatefulWidget {
  final GlobalKey<FormState>? formKey;

  const HospitalFields({super.key, this.formKey});

  @override
  HospitalFieldsState createState() => HospitalFieldsState();
}

class HospitalFieldsState extends State<HospitalFields> {
  // Controllers
  final TextEditingController hospitalNameController = TextEditingController();
  final TextEditingController administrationController =
      TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Initialize with valid values
  String selectedSpecialty = "عام";
  String selectedCity = "بغداد";
  String selectedDistrict = "الأعظمية";
  String typedAvailabilityTime = "03:00 مساء - 11:00 مساء";
  List<String> typedDays = [];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          // Hospital Name Field
          TextFormField(
            controller: hospitalNameController,
            decoration: const InputDecoration(
              labelText: 'اسم المستشفى',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return "اسم المستشفى مطلوب";
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          // Specialty Dropdown
          DropdownButtonFormField<String>(
            value: selectedSpecialty,
            items: const [
              DropdownMenuItem(value: 'عام', child: Text('عام')),
              DropdownMenuItem(value: 'جراحي', child: Text('جراحي')),
              DropdownMenuItem(value: 'تخصصي', child: Text('تخصصي')),
              DropdownMenuItem(value: 'تعليمي', child: Text('تعليمي')),
              DropdownMenuItem(value: 'اخرى', child: Text('اخرى')),
            ],
            onChanged: (newValue) =>
                setState(() => selectedSpecialty = newValue ?? 'عام'),
            decoration: const InputDecoration(
              labelText: 'التخصص',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                (value?.isEmpty ?? true) ? "اختر التخصص" : null,
          ),
          const SizedBox(height: 10),

          // Administration Field
          TextFormField(
            controller: administrationController,
            decoration: const InputDecoration(
              labelText: 'الإدارة',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                (value?.trim().isEmpty ?? true) ? "حقل الإدارة مطلوب" : null,
          ),
          const SizedBox(height: 10),

          // Bio Field
          TextFormField(
            controller: bioController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Bio',
              border: OutlineInputBorder(),
            ),
            validator: (value) => (value?.trim().isEmpty ?? true)
                ? "يرجى إدخال معلومات عن المستشفى"
                : null,
          ),
          const SizedBox(height: 10),

          // Phone Field
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            maxLength: 10, // Limits to 10 digits
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Only allow numbers
              LengthLimitingTextInputFormatter(10), // Hard stop at 10 digits
            ],
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.phone),
              labelText: 'رقم المحمول',
              alignLabelWithHint: true,
              prefixText: '+964 ', // Fixed prefix
              counterText: '', // Hide character counter
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.fromLTRB(12, 16, 16, 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال رقم الهاتف';
              }
              if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                return 'يجب أن يكون 10 أرقام (بدون +964)';
              }
              return null;
            },
          ), // ... rest of your code
        ],
      ),
    );
  }
}
