import 'package:flutter/material.dart';
import 'package:racheeta/features/doctors/screens/search_doctor_screen.dart';
import 'package:racheeta/features/screens/hsp_search_screen.dart';
import 'package:racheeta/theme/app_theme.dart';

import '../../../features/doctors/screens/specialty_doctors_screen.dart';

class HeaderOption extends StatelessWidget {
  HeaderOption({super.key, required this.iconPath, required this.label});

  final String iconPath;
  final String label;

  final Map<String, String> specialtyMapping = const {
    'اشعة': 'أشعات و رنين',
    'سونار': 'أشعات و رنين',
    'مفراس': 'أشعات و رنين',
    'رنين': 'أشعات و رنين',
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openService(context),
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: RacheetaColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: RacheetaColors.mintLight.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset(
                    iconPath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.medical_services_outlined,
                      color: RacheetaColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 13.5,
                        height: 1.2,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openService(BuildContext context) {
    if (label == 'حجز في عيادة') {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchDoctorPage()));
      return;
    }

    if (label == 'اسنان') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SpecialtyDoctorsPage(specialty: 'اسنان')),
      );
      return;
    }

    if (label == 'طبيب دولي') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SpecialtyDoctorsPage(
            specialty: 'طبيب دولي',
            isInternational: true,
          ),
        ),
      );
      return;
    }

    if (label == 'نفسية') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SpecialtyDoctorsPage(specialty: 'نفسية')),
      );
      return;
    }

    if (label == 'أشعات و رنين') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SpecialtyDoctorsPage(specialty: 'xsonarrays')),
      );
      return;
    }

    if (specialtyMapping.containsKey(label)) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SpecialtyDoctorsPage(specialty: specialtyMapping[label]!),
        ),
      );
      return;
    }

    final serviceType = getServiceTypeFromLabel(label);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HSPSearchScreen(hspType: serviceType)),
    );
  }

  String getServiceTypeFromLabel(String label) {
    switch (label) {
      case 'مستشفى':
        return 'Hospital';
      case 'صيدلية':
        return 'Pharmacy';
      case 'علاج طبيعي':
        return 'Therapist';
      case 'مركز طبي':
        return 'MedicalCenter';
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
      default:
        return 'Unknown';
    }
  }
}
