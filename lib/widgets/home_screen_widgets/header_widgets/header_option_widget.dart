import 'package:flutter/material.dart';
import 'package:racheeta/features/doctors/screens/search_doctor_screen.dart';
import 'package:racheeta/features/screens/hsp_search_screen.dart';
import '../../../features/doctors/screens/specialty_doctors_screen.dart';

class HeaderOption extends StatelessWidget {
  final String iconPath;
  final String label;

  HeaderOption({required this.iconPath, required this.label});
  Map<String, String> specialtyMapping = {
    'اشعة': 'أشعات و رنين',
    'سونار': 'أشعات و رنين',
    'مفراس': 'أشعات و رنين',
    'رنين': 'أشعات و رنين',
  };
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to different screens based on the label
        if (label == 'حجز في عيادة') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SearchDoctorPage(),
            ),
          );
        } else if (label == 'اسنان') {
          // Navigate to Dentist specialty page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SpecialtyDoctorsPage(specialty: 'اسنان'),
            ),
          );
        } else if (label == 'طبيب دولي') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SpecialtyDoctorsPage(
                specialty: 'طبيب دولي',
                isInternational: true, // Key flag
              ),
            ),
          );
        } else if (label == 'نفسية') {
          // Navigate to Psychology specialty page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SpecialtyDoctorsPage(specialty: 'نفسية'),
            ),
          );
        } else if (label == 'أشعات و رنين') {
          // Go to a doctor listing for x-ray/sonar
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  SpecialtyDoctorsPage(specialty: 'xsonarrays'),
            ),
          );
        } else if (specialtyMapping.containsKey(label)) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SpecialtyDoctorsPage(
                specialty: specialtyMapping[label]!, // Unified specialty
              ),
            ),
          );
        } else {
          // Map the label to corresponding HSP type
          String serviceType = getServiceTypeFromLabel(label);
          print("serviceType $serviceType");
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HSPSearchScreen(hspType: serviceType),
            ),
          );
        }
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  iconPath,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to map the label to the appropriate service type
  String getServiceTypeFromLabel(String label) {
    switch (label) {
      case 'مستشفى':
        return 'Hospital'; // matches if (widget.hspType == 'Hospital')
      case 'صيدلية':
        return 'Pharmacy'; // matches if (widget.hspType == 'Pharmacy')
      case 'علاج طبيعي':
        return 'Therapist'; // matches if (widget.hspType == 'Therapist')
      // case 'زيارة منزلية':
      //   return 'Nurse'; // matches if (widget.hspType == 'Nurse')
      case 'مركز طبي':
        return 'MedicalCenter'; // then add else if (widget.hspType == 'MedicalCenter')
      case 'تجميل':
        return 'BeautyCenter';
      case 'مختبرات':
        return 'Labrotary';
      case 'تمريض':
        return 'Nurse';
      case 'اسنان':
        return 'Dentist';
      case 'بيطري':
        return 'veterinarian';
      case 'نفسية':
        return 'psychologist';
      case 'أشعات و رنين':
        return 'xsonarrays';
      case 'طبيب دولي':
        return 'internationaldoctor';
      // etc...
      default:
        return 'Unknown';
    }
  }
}
