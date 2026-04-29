import 'package:flutter/material.dart';

class NurseFields extends StatefulWidget {
  final GlobalKey<FormState>? formKey; // optional if you want a Form

  const NurseFields({
    Key? key,
    this.formKey,
  }) : super(key: key);

  @override
  NurseFieldsState createState() => NurseFieldsState();
}

class NurseFieldsState extends State<NurseFields> {
  final TextEditingController bioController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String selectedSpecialty = "";
  String selectedDegree = "";

  // Getters for accessing field values
  String get bio => bioController.text;
  String get specialty => selectedSpecialty;
  String get degree => selectedDegree;

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
              DropdownMenuItem(child: Text('ممرض جامعي'), value: 'University'),
              DropdownMenuItem(child: Text('جراحة وتداوي'), value: 'Surgery'),
              DropdownMenuItem(child: Text('عمليات صغرى'), value: 'Pediatrics'),
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
              DropdownMenuItem(child: Text('اعدادية تمريض'), value: 'Bacloria'),
              DropdownMenuItem(child: Text('Diploma'), value: 'Diploma'),
              DropdownMenuItem(child: Text('بكلريوس'), value: 'BSc'),
              DropdownMenuItem(child: Text('ماجستير'), value: 'Msc'),
              DropdownMenuItem(child: Text('دكتوراة'), value: 'Phd'),
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    bioController.dispose();
    super.dispose();
  }
}
