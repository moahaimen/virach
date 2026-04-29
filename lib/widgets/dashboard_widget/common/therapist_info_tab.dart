// lib/widgets/dashboard_widget/therapist/therapist_info_tab.dart
import 'package:flutter/material.dart';
import '../common/labeled_text_field.dart';
import '../common/labeled_dropdown.dart';

class TherapistInfoTab extends StatelessWidget {
  final String selectedSpecialty;
  final List<Map<String, dynamic>> specialties;
  final ValueChanged<String> onSpecialtyChanged;

  final String selectedDegree;
  final List<String> degreeOptions;
  final ValueChanged<String> onDegreeChanged;

  final String selectedCountry;
  final List<String> countryOptions;
  final ValueChanged<String> onCountryChanged;

  final TextEditingController priceController;
  final TextEditingController availabilityController;

  final bool voiceCall;
  final bool videoCall;
  final ValueChanged<bool> onVoiceChanged;
  final ValueChanged<bool> onVideoChanged;

  final bool isEditMode;

  const TherapistInfoTab({
    Key? key,
    required this.selectedSpecialty,
    required this.specialties,
    required this.onSpecialtyChanged,
    required this.selectedDegree,
    required this.degreeOptions,
    required this.onDegreeChanged,
    required this.selectedCountry,
    required this.countryOptions,
    required this.onCountryChanged,
    required this.priceController,
    required this.availabilityController,
    required this.voiceCall,
    required this.videoCall,
    required this.onVoiceChanged,
    required this.onVideoChanged,
    required this.isEditMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          // ▼ التخصص
          LabeledDropdown(
            label: 'التخصص',
            value: selectedSpecialty,
            items: specialties.map((e) => e['label'] as String).toList(),
            enabled: isEditMode,
            onChanged: (val) {
              if (val != null) onSpecialtyChanged(val);
            },
          ),
          const SizedBox(height: 12),

          // ▼ الشهادة
          LabeledDropdown(
            label: 'الشهادة',
            value: selectedDegree,
            items: degreeOptions,
            enabled: isEditMode,
            onChanged: (val) {
              if (val != null) onDegreeChanged(val);
            },
          ),
          const SizedBox(height: 12),

          // ▼ الدولة
          LabeledDropdown(
            label: 'الدولة',
            value: selectedCountry,
            items: countryOptions,
            enabled: isEditMode,
            onChanged: (val) {
              if (val != null) onCountryChanged(val);
            },
          ),
          const SizedBox(height: 12),

          // ▼ السعر
          LabeledTextField(
            label: 'سعر الجلسة (اختياري)',
            controller: priceController,
            keyboardType: TextInputType.number,
            enabled: isEditMode,
          ),
          const SizedBox(height: 12),

          // ▼ أوقات التوفر
          LabeledTextField(
            label: 'أوقات التوفر',
            controller: availabilityController,
            enabled: isEditMode,
          ),
          const SizedBox(height: 12),

          // ▼ خيارات الاتصال
          CheckboxListTile(
            title: const Text('مكالمات صوتية'),
            value: voiceCall,
            onChanged: isEditMode ? (val) => onVoiceChanged(val ?? false) : null,
          ),
          CheckboxListTile(
            title: const Text('مكالمات فيديو'),
            value: videoCall,
            onChanged: isEditMode ? (val) => onVideoChanged(val ?? false) : null,
          ),
        ],
      ),
    );
  }
}
