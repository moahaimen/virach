import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BeautyCentersFields extends StatefulWidget {
  final GlobalKey<FormState>? formKey; // If you want to validate

  const BeautyCentersFields({Key? key, this.formKey}) : super(key: key);

  @override
  BeautyCentersFieldsState createState() => BeautyCentersFieldsState();
}

class BeautyCentersFieldsState extends State<BeautyCentersFields> {
  // Controllers
  final TextEditingController centerNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Some example fields
  String selectedCity = "بغداد";
  String selectedDistrict = "الأعظمية";

  // -- Getters for submission
  String get centerName => centerNameController.text.trim();
  String get bio => bioController.text.trim();
  String get phone => phoneController.text.trim();

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: widget.formKey, // The same key from parent
      child: Column(
        children: [
          // Center name
          TextFormField(
            controller: centerNameController,
            decoration: const InputDecoration(
              labelText: 'اسم المركز',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'أدخل اسم المركز';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Bio
          TextFormField(
            controller: bioController,
            decoration: const InputDecoration(
              labelText: 'Bio',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'أدخل معلومات عن المركز (Bio)';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Phone
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
              if (value == null || value.isEmpty)
                return 'يرجى إدخال رقم الهاتف';
              if (!RegExp(r'^[0-9]{10}$').hasMatch(value))
                return 'يجب أن يكون 10 أرقام (بدون +964)';
              return null;
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  void dispose() {
    centerNameController.dispose();
    bioController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
