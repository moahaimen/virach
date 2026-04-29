import 'package:flutter/material.dart';
import '../../../../widgets/global_health_profile/custom_textformfield_widget.dart';
import '../../../../widgets/global_health_profile/buildLargeTextAreaField.dart';
import 'city_district_selection_page.dart';       // <-- already in your tree

class MedicalCenterFields extends StatefulWidget {
  final GlobalKey<FormState>? formKey;

  // basic data
  final TextEditingController centerNameController;
  final TextEditingController directorNameController;
  final TextEditingController bioController;
  final TextEditingController phoneController;

  // city / district
  final String selectedCity;
  final String selectedDistrict;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<String> onDistrictChanged;

  const MedicalCenterFields({
    Key? key,
    required this.formKey,
    required this.centerNameController,
    required this.directorNameController,
    required this.bioController,
    required this.phoneController,
    required this.selectedCity,
    required this.selectedDistrict,
    required this.onCityChanged,
    required this.onDistrictChanged,
  }) : super(key: key);

  @override
  State<MedicalCenterFields> createState() => _MedicalCenterFieldsState();
}

class _MedicalCenterFieldsState extends State<MedicalCenterFields> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          /* ────────────── اسم المركز ────────────── */
          CustomTextFormFieldWidget(
            hint      : 'اسم المركز',
            label     : 'اسم المركز',
            controller: widget.centerNameController,
            validator : (v) =>
            (v == null || v.trim().isEmpty) ? 'يرجى إدخال اسم المركز' : null,
          ),
          const SizedBox(height: 8),

          /* ────────────── مدير المركز ────────────── */
          CustomTextFormFieldWidget(
            hint      : 'اسم المدير',
            label     : 'مدير المركز',
            controller: widget.directorNameController,
            validator : (v) =>
            (v == null || v.trim().isEmpty) ? 'يرجى إدخال اسم مدير المركز' : null,
          ),
          const SizedBox(height: 8),

          /* ────────────── نبذة ────────────── */
          buildLargeTextAreaField(
            'نبذة عن المركز',
            widget.bioController,
            validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'يرجى إدخال نبذة عن المركز' : null,
          ),
          const SizedBox(height: 8),

          /* ────────────── الهاتف ────────────── */
          CustomTextFormFieldWidget(
            hint      : 'رقم الهاتف',
            label     : 'رقم الهاتف',
            controller: widget.phoneController,
            isPhone   : true,
            validator : (v) =>
            (v == null || v.trim().isEmpty) ? 'يرجى إدخال رقم الهاتف' : null,
          ),
          const SizedBox(height: 8),

          /* ────────────── المدينة / الحي ────────────── */
          CityDistrictSelection(
            selectedCity     : widget.selectedCity,
            selectedDistrict : widget.selectedDistrict,
            onCityChanged    : widget.onCityChanged,
            onDistrictChanged: widget.onDistrictChanged,
          ),
        ],
      ),
    );
  }
}
