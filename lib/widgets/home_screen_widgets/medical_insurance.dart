import 'package:flutter/material.dart';
import '../../features/doctors/screens/specialty_doctors_screen.dart';

/// ============================
/// MedicalInsuranceSection
/// ============================
class MedicalInsuranceSection extends StatelessWidget {
  const MedicalInsuranceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: ListTile(
          leading: Icon(
            Icons.security,
            size: 40,
            color: colorScheme.primary,
          ),
          title: Text(
            'تأميني الطبي',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            'احجز دكتور واطلب دواء بالتأمين.',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: colorScheme.primary,
            size: 20,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SpecialtyDoctorsPage(specialty: "تأمين"),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ============================
/// Veterian
/// ============================
class Veterian extends StatelessWidget {
  const Veterian({super.key});

  // Make these static const so there are no “undefined name” errors
  static const String imagePath = 'assets/icons/venterian.png';
  static const String title = 'اعتني بحيوانك الاليف';
  static const String description =
      'اختر اقرب عيادة اليك للعناية بحيوانك الاليف';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SpecialtyDoctorsPage(specialty: "بيطري"),
          ),
        );
      },
      child: Card(
        color: colorScheme.surface,
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 4,
        child: Row(
          children: [
            // ─── Text & Button Section ───────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    // Description
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 20.0),
                    // “احجز الآن” Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const SpecialtyDoctorsPage(specialty: title),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondaryContainer,
                          foregroundColor: colorScheme.onSecondaryContainer,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          // ← Explicitly set a TextStyle with inherit: true
                          textStyle: const TextStyle(
                            inherit: true,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('احجز الآن'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Image Section ───────────────────────────────
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.asset(
                  imagePath,
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.25,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
