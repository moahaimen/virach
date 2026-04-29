import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LaboratoryFields extends StatefulWidget {
  final GlobalKey<FormState>? formKey;

  const LaboratoryFields({super.key, this.formKey});

  @override
  LaboratoryFieldsState createState() => LaboratoryFieldsState();
}

class LaboratoryFieldsState extends State<LaboratoryFields> {
  // Controllers
  final TextEditingController labNameController = TextEditingController();
  final TextEditingController availableTestsController =
      TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Selections
  String selectedCity = "بغداد";
  String selectedDistrict = "الأعظمية";
  String selectedAvailabilityTime = "24/7";
  List<String> typedDays = [];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          // Laboratory Name Field
          TextFormField(
            controller: labNameController,
            decoration: const InputDecoration(
              labelText: 'اسم المختبر',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return "اسم المختبر مطلوب";
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          // Available Tests Field
          TextFormField(
            controller: availableTestsController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'الفحوصات المتاحة',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return "يرجى إدراج الفحوصات المتاحة";
              }
              return null;
            },
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
                ? "يرجى إدخال معلومات عن المختبر"
                : null,
          ),
          const SizedBox(height: 10),

          // Phone Field (Matching Hospital Style)
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            maxLength: 10,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.phone),
              labelText: 'رقم المحمول',
              alignLabelWithHint: true,
              prefixText: '+964 ',
              counterText: '',
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
          ),
        ],
      ),
    );
  }

  // Helper method to get form data
  Map<String, dynamic> getLabData() {
    return {
      "laboratory_name": labNameController.text.trim(),
      "available_tests": availableTestsController.text.trim(),
      "bio": bioController.text.trim(),
      "address": "$selectedCity - $selectedDistrict",
      "availability_time": selectedAvailabilityTime,
      "phone": "+964${phoneController.text.trim()}",
    };
  }
}
