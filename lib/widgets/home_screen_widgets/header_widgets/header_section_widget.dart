import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/header_option_provider.dart';
import 'header_option_widget.dart';

class HeaderSection extends StatelessWidget {
  final Map<String, String> iconPaths = {
    'حجز في عيادة': 'assets/icons/appointment.png',
    'طبيب دولي': 'assets/icons/appointment.png',
    'أشعات و رنين': 'assets/icons/x-ray.png',
    'اسنان': 'assets/icons/dentist.png',
    'تجميل': 'assets/icons/beauty.png',
    'علاج طبيعي': 'assets/icons/physio_therapist.png',
    'مختبرات': 'assets/icons/microscope.png',
    'نفسية': 'assets/icons/pshyco.png',
    'مركز طبي': 'assets/icons/medical_centre_home_icon.png',
    'مستشفى': 'assets/icons/hospital_home_icon.png',
    'صيدلية': 'assets/icons/pharmacy.png',
    // 'زيارة منزلية': 'assets/icons/doctor_visit.png',
    //'بيطري': 'assets/icons/venterian.png',
    'تمريض': 'assets/icons/nurse.png',
  };

  @override
  Widget build(BuildContext context) {
    print('Building HeaderSection widget...');
    final headerOptionProvider = Provider.of<HeaderOptionProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.0, // Adjust aspect ratio to fit more content
        ),
        itemCount: iconPaths.keys.length,
        itemBuilder: (context, index) {
          String label = iconPaths.keys.elementAt(index);
          String iconPath = iconPaths[label] ?? 'assets/icons/beuty.png';
          print('Building grid item: $label with iconPath: $iconPath');

          return GestureDetector(
            onTap: () {
              print('Tapped on: $label');
              headerOptionProvider.selectService(label);
              print(
                  'Service selected in provider: ${headerOptionProvider.selectedService}');
            },
            child: HeaderOption(iconPath: iconPath, label: label),
          );
        },
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
    );
  }
}
