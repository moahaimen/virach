import 'package:flutter/material.dart';
import '../../features/offers/screens/offers_screent.dart';
import '../../theme/app_theme.dart';

class OffersItem extends StatelessWidget {
  const OffersItem({super.key});

  @override
  Widget build(BuildContext context) {
    const String title = "عروض صحية قريبة منك";
    const String subtitle = "تابع أحدث عروض العيادات، المختبرات، الصيدليات ومراكز التجميل.";
    const String buttonText = "شاهد العروض";
    const String imagePath = 'assets/icons/beuty.png'; // Updated to a more appropriate icon for offers

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OffersScreen()),
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
                        MaterialPageRoute(builder: (_) => const OffersScreen()),
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
