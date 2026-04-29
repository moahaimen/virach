// basic_info_tab.dart
import 'package:flutter/material.dart';
import 'labeled_text_field.dart';
import 'labeled_dropdown.dart';

/// Tab widget that shows basic user information (name, gender, e‑mail, phone).
class BasicInfoTab extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final String? selectedGender;
  final List<String> genderOptions;
  final bool isEditMode;
  final void Function(String?)? onGenderChanged;

  const BasicInfoTab({
    Key? key,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.selectedGender,
    required this.genderOptions,
    required this.isEditMode,
    this.onGenderChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          LabeledTextField(
            label: 'الاسم الكامل',
            controller: fullNameController,
            enabled: isEditMode,
          ),
          const SizedBox(height: 12),
          LabeledDropdown(
            label: 'الجنس',
            value: selectedGender,
            items: genderOptions,
            enabled: isEditMode,
            onChanged: (String? val) {
              if (isEditMode && onGenderChanged != null) {
                onGenderChanged!(val);
              }
            },
          ),
          const SizedBox(height: 12),
          LabeledTextField(
            label: 'البريد الإلكتروني',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: isEditMode,
          ),
          const SizedBox(height: 12),
          LabeledTextField(
            label: 'رقم الهاتف',
            controller: phoneController,
            keyboardType: TextInputType.phone,
            enabled: isEditMode,
          ),
        ],
      ),
    );
  }
}
