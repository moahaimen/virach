import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../widgets/global_health_profile/buildLargeTextAreaField.dart';
import '../../../../widgets/global_health_profile/custom_textformfield_widget.dart';

class PharmacistFields extends StatefulWidget {
  final GlobalKey<FormState>? formKey;

  const PharmacistFields({Key? key, this.formKey}) : super(key: key);

  @override
  PharmacistFieldsState createState() => PharmacistFieldsState();
}

class PharmacistFieldsState extends State<PharmacistFields> {
  final TextEditingController pharmacyNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isNightPharmacy = false;

  // Public getters for parent access
  String get pharmacyName => pharmacyNameController.text.trim();
  String get bio => bioController.text.trim();
  String get phone => phoneController.text.trim();
  bool get sentinel => isNightPharmacy;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          // Pharmacy Name Field
          CustomTextFormFieldWidget(
            hint: 'اسم الصيدلية',
            label: 'اسم الصيدلية',
            controller: pharmacyNameController,
            validator: (value) {
              if (value == null || value.isEmpty) return 'مطلوب اسم الصيدلية';
              if (value.length < 3) return 'الاسم يجب أن يكون على الأقل 3 أحرف';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Bio Field
          buildLargeTextAreaField(
            'وصف الصيدلية',
            bioController,
            validator: (value) {
              if (value == null || value.isEmpty) return 'مطلوب وصف الصيدلية';
              if (value.length < 20)
                return 'الوصف يجب أن يكون على الأقل 20 حرف';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Phone Number Field
          CustomTextFormFieldWidget(
            hint: 'رقم الهاتف',
            label: 'رقم الهاتف',
            controller: phoneController,
            isPhone: true,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) return 'مطلوب رقم الهاتف';
              if (value.length != 10) return 'يجب أن يتكون من 10 أرقام';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Night Pharmacy Switch
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'صيدلية ليلية',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      isNightPharmacy ? 'نعم' : 'لا',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    Switch(
                      value: isNightPharmacy,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) =>
                          setState(() => isNightPharmacy = value),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    pharmacyNameController.dispose();
    bioController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
