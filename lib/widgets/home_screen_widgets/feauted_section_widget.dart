import 'package:flutter/material.dart';
import 'package:racheeta/theme/app_theme.dart';

class FeaturedSection extends StatelessWidget {
  const FeaturedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: RacheetaColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: RacheetaColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: RacheetaColors.mintLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.verified_outlined,
                color: RacheetaColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حجز صحي أوضح وأسرع',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: RacheetaColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'اختر الخدمة، قارن الخيارات، واحجز من مزودي خدمات قريبين منك.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: RacheetaColors.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
