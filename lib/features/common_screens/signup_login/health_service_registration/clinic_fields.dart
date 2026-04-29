import 'package:flutter/material.dart';
import '../../../../widgets/global_health_profile/custom_textformfield_widget.dart';

class ClinicFields extends StatelessWidget {
  final TextEditingController clinicNameController = TextEditingController();
  final TextEditingController workingHoursController = TextEditingController();
  final TextEditingController gpsLocationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextFormFieldWidget(
          hint: 'تخصص العيادة',
          label: 'تخصص العيادة',
          controller: clinicNameController,
        ),
        CustomTextFormFieldWidget(
          hint: 'اسم الدكتور',
          label: 'اسم الدكتور',
          controller: workingHoursController,
        ),
        CustomTextFormFieldWidget(
          hint: 'رقم الهاتف',
          label: 'رقم الهاتف',
          controller: phoneController,
          isPhone: true,
        ),
      ],
    );
  }
}
