import 'package:flutter/material.dart';
import 'labeled_text_field.dart';

class CenterInfoTab extends StatelessWidget {
  final TextEditingController centerNameController;
  final TextEditingController bioController;
  final TextEditingController availabilityController;
  final bool isEditMode;

  const CenterInfoTab({
    Key? key,
    required this.centerNameController,
    required this.bioController,
    required this.availabilityController,
    required this.isEditMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          LabeledTextField(
            label: 'اسم المركز',
            controller: centerNameController,
            enabled: isEditMode,
          ),
          const SizedBox(height: 12),
          LabeledTextField(
            label: 'نبذة عن المركز',
            controller: bioController,
            maxLines: 3,
            enabled: isEditMode,
          ),
          const SizedBox(height: 12),
          LabeledTextField(
            label: 'أوقات التوفر',
            controller: availabilityController,
            enabled: isEditMode,
          ),
        ],
      ),
    );
  }
}
