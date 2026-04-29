// lib/widgets/create_hsp/additional_step_widget.dart

import 'package:flutter/material.dart';
import '../../../widgets/global_health_profile/communication_checkboxes.dart';
import '../../../widgets/global_health_profile/gender_toggle_widget.dart';
import '../../../widgets/global_health_profile/home_visit_switch.dart';
import '../../../widgets/global_health_profile/time_and_day_picker_widget.dart';
import '../../features/common_screens/signup_login/health_service_registration/city_district_selection_page.dart';

class AdditionalStepWidget extends StatelessWidget {
  final String userType;

  // الآن الدالة تاخذ باراميترين boolean بدل Tuple2
  final void Function(bool audio, bool video) onCheckboxChanged;
  final bool acceptAudioCalls;
  final bool acceptVideoCalls;

  final bool homeVisit;
  final ValueChanged<bool> onHomeVisitToggle;

  final int selectedGender;
  final ValueChanged<int> onGenderToggle;

  final String selectedCity;
  final String selectedDistrict;
  final void Function(String) onCityChanged;
  final void Function(String) onDistrictChanged;

  // الآن onSave يستقبل سلاسل نصية للوقت
  final void Function(String startTime, String endTime, List<String> days) onSaveTimeAndDays;

  final String? gpsLocation;
  final String statusMessage;
  final VoidCallback onRequestLocation;

  const AdditionalStepWidget({
    required this.userType,
    required this.acceptAudioCalls,
    required this.acceptVideoCalls,
    required this.onCheckboxChanged,
    required this.homeVisit,
    required this.onHomeVisitToggle,
    required this.selectedGender,
    required this.onGenderToggle,
    required this.selectedCity,
    required this.selectedDistrict,
    required this.onCityChanged,
    required this.onDistrictChanged,
    required this.onSaveTimeAndDays,
    required this.gpsLocation,
    required this.statusMessage,
    required this.onRequestLocation,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (userType == 'doctor' ||
              userType == 'nurse' ||
              userType == 'therapist')
            CommunicationCheckboxes(
              acceptAudioCalls: acceptAudioCalls,
              acceptVideoCalls: acceptVideoCalls,
              onCheckboxChanged: (audio, video) {
                onCheckboxChanged(audio, video);
              },
            ),

          if (userType == 'doctor' ||
              userType == 'nurse' ||
              userType == 'therapist')
            HomeVisitSwitch(
              homeVisit: homeVisit,
              onToggle: (value) {
                onHomeVisitToggle(value);
              },
            ),

          if (userType == 'doctor' ||
              userType == 'nurse' ||
              userType == 'therapist') ...[
            GenderToggleWidget(
              selectedGender: selectedGender,
              onToggle: (index) {
                onGenderToggle(index);
              },
            ),
            if (selectedGender == 0)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "يرجى اختيار الجنس",
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],

          CityDistrictSelection(
            selectedCity: selectedCity,
            selectedDistrict: selectedDistrict,
            onCityChanged: onCityChanged,
            onDistrictChanged: onDistrictChanged,
          ),

          TimeAndDayPicker(
            availableTimes: const [
              '03:00 مساء',
              '04:00 مساء',
              '05:00 مساء',
              '06:00 مساء',
              '07:00 مساء',
              '08:00 مساء',
              '09:00 مساء',
              '10:00 مساء',
              '11:00 مساء'
            ],
            availableDays: const [
              'السبت',
              'الأحد',
              'الإثنين',
              'الثلاثاء',
              'الاربعاء',
              'الخميس',
              'الجمعة'
            ],
            onSave: onSaveTimeAndDays,
          ),

          const SizedBox(height: 20),

          if (gpsLocation != null)
            Text("الموقع: $gpsLocation", style: const TextStyle(fontSize: 16)),

          if (statusMessage.isNotEmpty)
            Text(statusMessage, style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
