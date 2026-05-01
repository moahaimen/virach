import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:racheeta/theme/app_theme.dart';

import '../../../providers/header_option_provider.dart';
import 'header_option_widget.dart';

class HeaderSection extends StatelessWidget {
  HeaderSection({super.key});

  final Map<String, String> iconPaths = const {
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
    'تمريض': 'assets/icons/nurse.png',
  };

  @override
  Widget build(BuildContext context) {
    final headerOptionProvider = Provider.of<HeaderOptionProvider>(context, listen: false);
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 900 ? 6 : width >= 600 ? 4 : 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            title: 'ماذا تحتاج اليوم؟',
            subtitle: 'اختر الخدمة الصحية واحجز خلال دقائق',
          ),
          const SizedBox(height: 14),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.92,
            ),
            itemCount: iconPaths.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final label = iconPaths.keys.elementAt(index);
              final iconPath = iconPaths[label] ?? 'assets/icons/appointment.png';

              return GestureDetector(
                onTap: () => headerOptionProvider.selectService(label),
                child: HeaderOption(iconPath: iconPath, label: label),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 34,
          decoration: BoxDecoration(
            color: RacheetaColors.primary,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
