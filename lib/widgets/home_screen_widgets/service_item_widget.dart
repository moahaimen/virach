import 'package:flutter/material.dart';
import '../../features/doctors/screens/search_doctor_screen.dart';
import '../../theme/app_theme.dart';

class ServiceItem extends StatelessWidget {
  const ServiceItem({super.key});

  @override
  Widget build(BuildContext context) {
    const String title = "استشارة أو حجز عيادة";
    const String subtitle = "ابحث حسب التخصص واحجز مع مزود خدمة مناسب لك بسرعة.";
    const String buttonText = "ابدأ الحجز";
    const String imagePath = 'assets/icons/appointment.png';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SearchDoctorPage()),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        color: RacheetaColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: RacheetaColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            color: RacheetaColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                          ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SearchDoctorPage()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RacheetaColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(120, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        buttonText,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Image.asset(
                imagePath,
                width: 110,
                height: 110,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
